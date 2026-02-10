locals {
  domain_name = var.domain_name
  subdomain_name = var.subdomain_name
  fqdn = "${var.subdomain_name}.${var.domain_name}"
}

data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}