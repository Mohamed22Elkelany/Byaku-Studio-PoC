resource "aws_lb_listener" "this" {
  port              = var.port
  protocol          = var.protocol
  certificate_arn   = var.certificate_arn
  ssl_policy        = var.ssl_policy
  load_balancer_arn = var.load_balancer_arn

  dynamic "default_action" {
    for_each = var.default_action != null ? [1] : []

    content {
      type             = var.default_action.type
      target_group_arn = var.default_action.target_group_arn
      dynamic "fixed_response" {
        for_each = var.default_action.fixed_response != null ? [1] : []

        content {
          content_type = var.default_action.fixed_response.content_type
          status_code  = var.default_action.fixed_response.status_code
          message_body = var.default_action.fixed_response.message_body
        }
      }

      dynamic "redirect" {
        for_each = var.default_action.redirect != null ? [1] : []

        content {
          port        = var.default_action.redirect.port
          protocol    = var.default_action.redirect.protocol
          status_code = var.default_action.redirect.status_code
        }
      }

      dynamic "forward" {
        for_each = var.default_action.forward != null ? [1] : []

        content {
          dynamic "target_group" {
            for_each = var.default_action.forward.target_groups != null ? var.default_action.forward.target_groups : []
            content {
              arn    = target_group.value.arn
              weight = target_group.value.weight
            }
          }

          dynamic "stickiness" {
            for_each = var.default_action.forward.stickiness != null ? [1] : []
            content {
              enabled  = var.default_action.forward.stickiness.enabled
              duration = var.default_action.forward.stickiness.duration
            }
          }
        }
      }
    }
  }

  tags = merge(local.default_tags, var.tags, {
    Name     = var.listener_name
    Protocol = var.protocol
  })
}
