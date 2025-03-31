locals {
  ttl = 1
}

resource "cloudflare_dns_record" "gitlab-main" {
  name    = var.main_domain
  type    = "A"
  content = yandex_vpc_address.traefik-address.external_ipv4_address[0].address
  ttl     = local.ttl
  zone_id = var.cloudflare_zone_id
  proxied = true
}

resource "cloudflare_dns_record" "gitlab-extra" {
  name    = "*.${var.main_domain}"
  type    = "CNAME"
  content = cloudflare_dns_record.gitlab-main.name
  ttl     = local.ttl
  zone_id = var.cloudflare_zone_id
  proxied = true
}
