locals {
  amqp_credentials = var.cloudamqp.enabled ? regex(
    ".+//(?P<user>.+):(?P<pass>.+)@", cloudamqp_instance.i[0].url
  ) : {}
}

resource "cloudamqp_instance" "i" {
  count               = var.cloudamqp.enabled ? 1 : 0
  name                = azurerm_resource_group.i.name
  plan                = var.cloudamqp.plan
  region              = var.cloudamqp.region
  vpc_id              = var.cloudamqp.vpc_id
  keep_associated_vpc = true
}

data "cloudamqp_nodes" "i" {
  count       = var.cloudamqp.enabled ? 1 : 0
  instance_id = cloudamqp_instance.i[0].id
}

data "dns_a_record_set" "cloudamqp_nodes" {
  for_each = { for k, v in try(data.cloudamqp_nodes.i[0].nodes, {}) : k => v }
  host     = each.value.hostname
}

resource "cloudamqp_privatelink_azure" "i" {
  count                  = var.cloudamqp.enabled ? 1 : 0
  instance_id            = cloudamqp_instance.i[0].id
  approved_subscriptions = [data.azurerm_subscription.i.subscription_id]
}

resource "cloudamqp_security_firewall" "i" {
  count       = var.cloudamqp.enabled ? 1 : 0
  instance_id = cloudamqp_instance.i[0].id

  rules {
    description = "Private Link"
    ip          = var.cloudamqp.subnet
    services    = ["AMQPS", "HTTPS"]
  }
  dynamic "rules" {
    for_each = concat(var.allowed_hosts.ipv4, [var.firewall.v4_prefix])
    content {
      ip       = rules.value
      services = ["HTTPS"]
    }
  }

  depends_on = [cloudamqp_privatelink_azure.i]
}

resource "azurerm_private_endpoint" "amqp" {
  count               = var.cloudamqp.enabled ? 1 : 0
  name                = "${azurerm_resource_group.i.name}-cloudamqp"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  subnet_id           = azurerm_subnet.cloudamqp.id

  private_service_connection {
    name                              = "cloudamqp-${cloudamqp_privatelink_azure.i[0].server_name}"
    private_connection_resource_alias = cloudamqp_privatelink_azure.i[0].service_name
    is_manual_connection              = true
    request_message                   = "PL"
  }
}

resource "azurerm_private_dns_zone" "amqp" {
  name                = "cloudamqp.com"
  resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "amqp" {
  name                  = "cloudamqp.com"
  private_dns_zone_name = azurerm_private_dns_zone.amqp.name
  virtual_network_id    = azurerm_virtual_network.i.id
  resource_group_name   = azurerm_resource_group.i.name
}

resource "azurerm_private_dns_a_record" "ampq" {
  count               = var.cloudamqp.enabled ? 1 : 0
  name                = "${split(".", cloudamqp_instance.i[0].host)[0]}.${split(".", cloudamqp_instance.i[0].host)[1]}"
  zone_name           = azurerm_private_dns_zone.amqp.name
  resource_group_name = azurerm_resource_group.i.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.amqp[0].private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "https" {
  for_each            = { for k, v in data.dns_a_record_set.cloudamqp_nodes : k => v }
  name                = "${split(".", each.value.host)[0]}.${split(".", each.value.host)[1]}"
  zone_name           = azurerm_private_dns_zone.amqp.name
  resource_group_name = azurerm_resource_group.i.name
  ttl                 = 300
  records             = each.value.addrs
}

resource "azurerm_key_vault_secret" "amqp" {
  count = var.cloudamqp.enabled ? 1 : 0

  name         = "infra-cloudamqp-connection-details"
  key_vault_id = azurerm_key_vault.i.id
  content_type = "application/json"
  value = jsonencode({
    "url"             = "amqps://${local.amqp_credentials.user}:${local.amqp_credentials.pass}@${cloudamqp_instance.i[0].host}/${local.amqp_credentials.user}"
    "user"            = local.amqp_credentials.user
    "cloudamqp_user"  = local.amqp_credentials.user
    "pass"            = local.amqp_credentials.pass
    "cloudamqp_pass"  = local.amqp_credentials.pass
    "host"            = cloudamqp_instance.i[0].host
    "cloudamqp_host"  = cloudamqp_instance.i[0].host
    "vhost"           = local.amqp_credentials.user
    "admin"           = "https://${cloudamqp_instance.i[0].host}/\n"
    "cloudamqp_nodes" = join(",", [for each in data.cloudamqp_nodes.i[0].nodes : each.hostname])
  })
  tags = {
    kube_secret_name = "azure-cloudamqp"
  }

  depends_on = [azurerm_key_vault_access_policy.iam_su]
}

resource "azurerm_key_vault_secret" "cloudamqp" {
  for_each = var.cloudamqp.enabled ? merge({
    "host" : cloudamqp_instance.i[0].host,
    "url" : "amqps://${local.amqp_credentials.user}:${local.amqp_credentials.pass}@${cloudamqp_instance.i[0].host}/${local.amqp_credentials.user}",
    "username" : local.amqp_credentials.user,
    "password" : local.amqp_credentials.pass,
  }, { for node in data.cloudamqp_nodes.i[0].nodes : "node-${reverse(split("-", node.name))[0]}" => node.hostname }) : {}
  name         = "infra-cloudamqp-${each.key}"
  key_vault_id = azurerm_key_vault.i.id
  content_type = "text/plain"
  value        = each.value

  depends_on = [azurerm_key_vault_access_policy.iam_su]
}
