locals {
  module_name       = "tf-aws/waf"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName    = local.module_name
    ModuleVersion = local.module_version
  }
}

resource "aws_wafv2_web_acl" "main" {
  count = var.enabled ? 1 : 0

  name        = var.name
  scope       = var.scope
  description = var.description

  default_action {
    dynamic "allow" {
      for_each = var.allow_default_action ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.allow_default_action ? [] : [1]
      # Despite seemingly would want to add default custom_response defintions here, the docs state an empty configuration block is required. ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#default-action
      content {}
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")

      dynamic "action" {
        for_each = length(lookup(rule.value, "action", {})) == 0 ? [] : [1]
        content {
          dynamic "allow" {
            for_each = lookup(rule.value, "action", {}) == "allow" ? [1] : []
            content {}
          }

          dynamic "count" {
            for_each = lookup(rule.value, "action", {}) == "count" ? [1] : []
            content {}
          }

          dynamic "captcha" {
            for_each = lookup(rule.value, "action", {}) == "captcha" ? [1] : []
            content {}
          }

          dynamic "challenge" {
            for_each = lookup(rule.value, "action", {}) == "challenge" ? [1] : []
            content {}
          }

          dynamic "block" {
            for_each = lookup(rule.value, "action", {}) == "block" ? [1] : []
            content {
              dynamic "custom_response" {
                for_each = length(lookup(rule.value, "custom_response", [])) == 0 ? [] : [lookup(rule.value, "custom_response", {})]
                content {
                  custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                  response_code            = lookup(custom_response.value, "response_code", 403)
                  dynamic "response_header" {
                    for_each = lookup(custom_response.value, "response_headers", [])
                    content {
                      name  = lookup(response_header.value, "name")
                      value = lookup(response_header.value, "value")
                    }
                  }
                }
              }
            }
          }
        }
      }

      # Required for managed_rule_group_statements. Set to none, otherwise count to override the default action
      dynamic "override_action" {
        for_each = length(lookup(rule.value, "override_action", {})) == 0 ? [] : [1]
        content {
          dynamic "none" {
            for_each = lookup(rule.value, "override_action", {}) == "none" ? [1] : []
            content {}
          }

          dynamic "count" {
            for_each = lookup(rule.value, "override_action", {}) == "count" ? [1] : []
            content {}
          }
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = length(lookup(rule.value, "managed_rule_group_statement", {})) == 0 ? [] : [lookup(rule.value, "managed_rule_group_statement", {})]
          content {
            name        = lookup(managed_rule_group_statement.value, "name")
            vendor_name = lookup(managed_rule_group_statement.value, "vendor_name", "AWS")
            version     = lookup(managed_rule_group_statement.value, "version", null)

            dynamic "managed_rule_group_configs" {
              for_each = length(lookup(managed_rule_group_statement.value, "managed_rule_group_configs", {})) == 0 ? [] : [lookup(managed_rule_group_statement.value, "managed_rule_group_configs", {})]
              content {
                dynamic "aws_managed_rules_bot_control_rule_set" {
                  for_each = length(lookup(managed_rule_group_configs.value, "aws_managed_rules_bot_control_rule_set", {})) == 0 ? [] : [lookup(managed_rule_group_configs.value, "aws_managed_rules_bot_control_rule_set", {})]
                  content {
                    inspection_level = lookup(aws_managed_rules_bot_control_rule_set.value, "inspection_level")
                  }
                }
              }
            }

            dynamic "rule_action_override" {
              for_each = lookup(managed_rule_group_statement.value, "rule_action_overrides", [])
              content {
                name = rule_action_override.value["name"]
                dynamic "action_to_use" {
                  for_each = [rule_action_override.value["action_to_use"]]
                  content {
                    dynamic "count" {
                      for_each = lookup(action_to_use.value, "count", null) == null ? [] : [lookup(action_to_use.value, "count")]
                      content {}
                    }
                    dynamic "allow" {
                      for_each = lookup(action_to_use.value, "allow", null) == null ? [] : [lookup(action_to_use.value, "allow")]
                      content {}
                    }
                    dynamic "block" {
                      for_each = lookup(action_to_use.value, "block", null) == null ? [] : [lookup(action_to_use.value, "block")]
                      content {}
                    }
                    dynamic "captcha" {
                      for_each = lookup(action_to_use.value, "captcha", null) == null ? [] : [lookup(action_to_use.value, "captcha")]
                      content {}
                    }
                  }
                }
              }
            }
          }
        }


        dynamic "rate_based_statement" {
          for_each = length(lookup(rule.value, "rate_based_statement", {})) == 0 ? [] : [lookup(rule.value, "rate_based_statement", {})]
          content {
            limit              = lookup(rate_based_statement.value, "limit")
            aggregate_key_type = lookup(rate_based_statement.value, "aggregate_key_type", "IP")
          }
        }
      }

      dynamic "visibility_config" {
        for_each = length(lookup(rule.value, "visibility_config")) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-default-rule-metric-name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  tags = merge(local.default_tags, var.tags, {
  })

  dynamic "visibility_config" {
    for_each = length(var.visibility_config) == 0 ? [] : [var.visibility_config]
    content {
      cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
      metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-default-web-acl-metric-name")
      sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
    }
  }
}


# WAFv2 web acl association with ALB
resource "aws_wafv2_web_acl_association" "main" {
  count = var.enabled && var.create_alb_association && length(var.alb_arn_list) == 0 ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main[0].arn

  depends_on = [aws_wafv2_web_acl.main]
}

resource "aws_wafv2_web_acl_association" "alb_list" {
  count = var.enabled && var.create_alb_association && length(var.alb_arn_list) > 0 ? length(var.alb_arn_list) : 0

  resource_arn = var.alb_arn_list[count.index]
  web_acl_arn  = aws_wafv2_web_acl.main[0].arn

  depends_on = [aws_wafv2_web_acl.main]
}

# WAFv2 web acl logging configuration
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.enabled && var.create_logging_configuration ? 1 : 0

  log_destination_configs = var.log_destination_configs
  resource_arn            = aws_wafv2_web_acl.main[0].arn
}