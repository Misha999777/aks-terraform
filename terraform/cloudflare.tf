resource "cloudflare_record" "ns_records" {
  count   = 4
  zone_id = var.cloudflare_zone
  name    = var.cluster_domain_name
  type    = "NS"
  content = tolist(azurerm_dns_zone.main.name_servers)[count.index]
  ttl     = 3600
}
