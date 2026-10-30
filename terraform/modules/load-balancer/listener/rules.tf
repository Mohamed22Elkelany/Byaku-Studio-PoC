resource "aws_lb_listener_rule" "this" {
  count = try(length(var.rules), 0)

  listener_arn = aws_lb_listener.this.arn
  priority     = count.index + 1

  dynamic "action" {
    for_each = var.rules[count.index].actions != null ? var.rules[count.index].actions : []

    content {
      type = action.value.type

      dynamic "fixed_response" {
        for_each = action.value.fixed_response != null ? [action.value.fixed_response] : []

        content {
          content_type = fixed_response.value.content_type
          status_code  = fixed_response.value.status_code
          message_body = fixed_response.value.message_body
        }
      }

      dynamic "redirect" {
        for_each = action.value.redirect != null ? [action.value.redirect] : []

        content {
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          status_code = redirect.value.status_code
        }
      }

      dynamic "forward" {
        for_each = action.value.forward != null ? [action.value.forward] : []

        content {
          dynamic "target_group" {
            for_each = forward.value.target_groups != null ? forward.value.target_groups : []
            content {
              arn    = target_group.value.arn
              weight = target_group.value.weight
            }
          }

          dynamic "stickiness" {
            for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []
            content {
              enabled  = stickiness.value.enabled
              duration = stickiness.value.duration
            }
          }
        }
      }
    }
  }

  dynamic "condition" {
    for_each = var.rules[count.index].conditions != null ? var.rules[count.index].conditions : []

    content {
      dynamic "host_header" {
        for_each = condition.value.host_headers != null ? [1] : []
        content {
          values = condition.value.host_headers
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.path_patterns != null ? [1] : []
        content {
          values = condition.value.path_patterns
        }
      }

      dynamic "http_header" {
        for_each = condition.value.http_headers != null ? condition.value.http_headers : []
        content {
          http_header_name = http_header.value.header_name
          values           = http_header.value.values
        }
      }
    }
  }
}
