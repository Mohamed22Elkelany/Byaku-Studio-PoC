module "alb" {
  source = "./modules/load_balancer"

  load_balancer_name         = "${var.project}-alb-${var.environment}"
  load_balancer_internal     = var.alb_config.load_balancer_internal
  load_balancer_type         = var.alb_config.load_balancer_type
  drop_invalid_header_fields = var.alb_config.drop_invalid_header_fields
  security_group_ids         = [module.alb_sg.security_group_id]
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnet_ids

  # Stage 1 (https_enabled = false): HTTP only, routed by host header, so the
  # first apply works while the certificate waits for its validation CNAME.
  # Stage 2 (https_enabled = true, certificate ISSUED): port 80 redirects to 443.
  listeners = concat(
    [
      {
        name     = "http"
        port     = "80"
        protocol = "HTTP"
        default_action = var.https_enabled ? {
          type = "redirect"
          redirect = {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
          }
          fixed_response = null
          } : {
          type     = "fixed-response"
          redirect = null
          fixed_response = {
            content_type = "text/plain"
            status_code  = "404"
            message_body = "Not Found"
          }
        }
      }
    ],
    var.https_enabled ? [
      {
        name            = "https"
        port            = "443"
        protocol        = "HTTPS"
        ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
        certificate_arn = aws_acm_certificate.this.arn
        # Requests are routed by host header (aws_lb_listener_rule.app below);
        # anything else is rejected.
        default_action = {
          type = "fixed-response"
          fixed_response = {
            content_type = "text/plain"
            status_code  = "404"
            message_body = "Not Found"
          }
        }
      }
    ] : []
  )

  tags = merge(local.default_tags, var.tags)
}

module "alb_sg" {
  source        = "./modules/security_group"
  description   = var.alb_security_group_config.description
  vpc_id        = module.vpc.vpc_id
  name          = "${var.project}-alb-sg-${var.environment}"
  ingress_rules = var.alb_security_group_config.ingress_rules
  tags          = merge(local.default_tags, var.tags)
}

###########################################
##   Application routing (host based)    ##
###########################################
# One target group per public service, registered by the ECS services.
resource "aws_lb_target_group" "app" {
  for_each = local.alb_services

  name                 = "${local.name}-${each.key}"
  port                 = local.ecs_service_ports[each.key]
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# app -> web, admin -> admin-web (private source ranges only), api -> backend.
resource "aws_lb_listener_rule" "app" {
  for_each = local.alb_services

  # https once enabled, otherwise the plain HTTP listener.
  listener_arn = module.alb.listeners_arns[var.https_enabled ? 1 : 0]
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[each.key].arn
  }

  condition {
    host_header {
      values = [each.value.host]
    }
  }

  # Keep the admin surface private.
  dynamic "condition" {
    for_each = each.key == "admin-web" ? [1] : []
    content {
      source_ip {
        values = length(var.admin_allowed_cidrs) > 0 ? var.admin_allowed_cidrs : [var.vpc_cidr]
      }
    }
  }
}
