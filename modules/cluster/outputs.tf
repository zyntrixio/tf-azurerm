output "frontdoor_backend_pool" {
    value = {
        host_header = trimsuffix(azurerm_dns_a_record.api_record.fqdn, ".")
        address = trimsuffix(azurerm_dns_a_record.api_record.fqdn, ".")
        http_port = var.firewall.ingress_http
        https_port = var.firewall.ingress_https
    }
}

output "frontdoor_backend_policies_pool" {
    value = {
        host_header = trimsuffix(azurerm_dns_a_record.policies_record.fqdn, ".")
        address = trimsuffix(azurerm_dns_a_record.policies_record.fqdn, ".")
        http_port = var.firewall.ingress_http
        https_port = var.firewall.ingress_https
    }
}

output "worker_subnet" {
    value = azurerm_subnet.worker.id
}
