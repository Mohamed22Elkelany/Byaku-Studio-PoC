module "waf_log_group" {
  source = "./modules/cloudwatch_log_group"

  name              = "aws-waf-logs-${var.project}-${var.waf.name}-log-group-${var.environment}"
  log_group_class   = "STANDARD"
  retention_in_days = var.waf.log_retention_in_days
  tags              = merge(local.default_tags, var.tags)
}

# Regional web ACL attached to the ALB (Cloudflare -> WAF -> ALB).
module "waf" {
  source = "./modules/waf"

  name                   = "${var.project}-${var.waf.name}-${var.environment}"
  allow_default_action   = var.waf.allow_default_action
  create_alb_association = var.waf.create_alb_association
  alb_arn                = module.alb.load_balancer_arn
  scope                  = var.waf.scope
  visibility_config = {
    cloudwatch_metrics_enabled = var.waf.cloudwatch_metrics_enabled
    metric_name                = "${var.project}-${var.waf.name}-metric-${var.environment}"
    sampled_requests_enabled   = var.waf.sampled_requests_enabled
  }

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = "1"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesCommonRuleSet-metric"
        sampled_requests_enabled   = true
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = "2"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesKnownBadInputsRuleSet-metric"
        sampled_requests_enabled   = true
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    },
    {
      name     = "AWSManagedRulesBotControlRuleSet"
      priority = "3"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesBotControlRuleSet-metric"
        sampled_requests_enabled   = true
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
        # HTTP-library / non-browser clients (API callers, webhooks, curl) are counted
        # and labelled, not blocked; the rest of Bot Control keeps blocking.
        rule_action_overrides = [
          {
            name = "CategoryHttpLibrary"
            action_to_use = {
              count = {}
            }
          },
          {
            name = "SignalNonBrowserUserAgent"
            action_to_use = {
              count = {}
            }
          }
        ]
      }
    },
    {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = "4"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesAmazonIpReputationList-metric"
        sampled_requests_enabled   = true
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    },
    {
      name     = "AWSManagedRulesLinuxRuleSet"
      priority = "5"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesLinuxRuleSet-metric"
        sampled_requests_enabled   = true
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    },
    {
      name     = "AWSManagedRulesAnonymousIpList"
      priority = "6"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesAnonymousIpList-metric"
        sampled_requests_enabled   = true
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }
  ]

  create_logging_configuration = var.waf.create_logging_configuration
  log_destination_configs      = [module.waf_log_group.cloudwatch_log_group_arn]
  tags                         = merge(local.default_tags, var.tags)

  depends_on = [module.waf_log_group]
}
