locals {
  module_name       = "tf-aws/target-group"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  dynamic "stickiness" {
    for_each = var.protocol == "HTTP" || var.protocol == "HTTPS" ? [true] : []
    content {
      enabled         = var.stickiness_enabled
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      cookie_name     = var.stickiness_cookie_name
    }
  }

  health_check {
    path                = (var.protocol == "HTTP" || var.protocol == "HTTPS") ? var.health_check_path : null
    protocol            = var.health_check_protocol
    interval            = var.interval
    timeout             = var.timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = (var.protocol == "HTTP" || var.protocol == "HTTPS") ? var.matcher : null
  }

  tags = merge(local.default_tags, var.tags)
}

resource "aws_lb_target_group_attachment" "this" {
  count = var.attach_target ? 1 : 0

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.attachment_target_id
  port             = var.attachment_target_port
}