###########################################################################
# Environment wildcard certificate (*.byaku-studio.com), DNS-validated by a CNAME
# in the byaku-studio.com zone (Cloudflare). Used by the public ALB HTTPS listener
# once https_enabled is set (see alb.tf).
###########################################################################
resource "aws_acm_certificate" "this" {
  domain_name       = var.acm_certificate_domain
  validation_method = "DNS"

  tags = { Name = local.name }

  lifecycle {
    create_before_destroy = true
  }
}
