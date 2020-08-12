output "frontdoor_backend_pool" {
    value = {
        host_header = trimsuffix(azurerm_dns_a_record.api_record.fqdn, ".")
        address = trimsuffix(azurerm_dns_a_record.api_record.fqdn, ".")
        http_port = var.firewall.ingress_http
        https_port = var.firewall.ingress_https
    }
}
