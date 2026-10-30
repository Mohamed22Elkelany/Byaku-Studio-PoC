###########################################################################
# OUT OF SCOPE (commented out): CloudFront + CloudFront-scoped WAF - not part of the current architecture (Cloudflare fronts the ALB).
###########################################################################

# module "cloudfront_waf_log_group" {
#   source = "./modules/cloudwatch_log_group"
#
#   name            = "aws-waf-logs-${var.project}-cloudfront-waf-${var.environment}"
#   log_group_class = "STANDARD"
#   tags            = merge(local.default_tags, var.tags)
# }
#
# module "cloudfront_waf" {
#   source = "./modules/waf"
#
#   name                   = "${var.project}-cloudfront-waf-${var.environment}"
#   scope                  = "CLOUDFRONT"
#   allow_default_action   = true
#   create_alb_association = false
#   visibility_config = {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${var.project}-cloudfront-waf-metric-${var.environment}"
#     sampled_requests_enabled   = true
#   }
#
#   rules = [
#     {
#       name            = "AWSManagedRulesCommonRuleSet"
#       priority        = "1"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "CloudFront-AWSManagedRulesCommonRuleSet-metric"
#         sampled_requests_enabled   = true
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     {
#       name            = "AWSManagedRulesKnownBadInputsRuleSet"
#       priority        = "2"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "CloudFront-AWSManagedRulesKnownBadInputsRuleSet-metric"
#         sampled_requests_enabled   = true
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesKnownBadInputsRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     {
#       name            = "AWSManagedRulesBotControlRuleSet"
#       priority        = "3"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "CloudFront-AWSManagedRulesBotControlRuleSet-metric"
#         sampled_requests_enabled   = true
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesBotControlRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     {
#       name            = "AWSManagedRulesAmazonIpReputationList"
#       priority        = "4"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "CloudFront-AWSManagedRulesAmazonIpReputationList-metric"
#         sampled_requests_enabled   = true
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesAmazonIpReputationList"
#         vendor_name = "AWS"
#       }
#     },
#     {
#       name            = "AWSManagedRulesLinuxRuleSet"
#       priority        = "5"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "CloudFront-AWSManagedRulesLinuxRuleSet-metric"
#         sampled_requests_enabled   = true
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesLinuxRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     {
#       name            = "AWSManagedRulesAnonymousIpList"
#       priority        = "6"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "CloudFront-AWSManagedRulesAnonymousIpList-metric"
#         sampled_requests_enabled   = true
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesAnonymousIpList"
#         vendor_name = "AWS"
#       }
#     }
#   ]
#
#   create_logging_configuration = true
#   log_destination_configs      = [module.cloudfront_waf_log_group.cloudwatch_log_group_arn]
#   tags                         = merge(local.default_tags, var.tags)
#
#   depends_on = [module.cloudfront_waf_log_group]
# }
#
# module "cloudfront" {
#   count  = var.cloudfront.enabled ? 1 : 0
#   source = "./modules/cloudfront"
#
#   enabled                    = var.cloudfront.enabled
#   aliases                    = var.cloudfront.aliases
#   comment                    = var.cloudfront.comment
#   is_ipv6_enabled            = var.cloudfront.is_ipv6_enabled
#   price_class                = var.cloudfront.price_class
#   web_acl_id                 = module.cloudfront_waf.web_acl_arn
#   domain_name                = module.s3_bucket.bucket_regional_domain_name
#   origin_id                  = "${var.project}-media-s3-${var.environment}"
#   target_origin_id           = "${var.project}-media-s3-${var.environment}"
#   origin_type                = "s3"
#   origin_access_control_name = "${var.project}-media-oac-${var.environment}"
#   origin_protocol_policy     = "https-only"
#   restriction_type           = var.cloudfront.restriction_type
#   locations                  = var.cloudfront.locations
#   acm_certificate_arn        = var.acm_certificate_arn
#   minimum_protocol_version   = var.cloudfront.minimum_tls_version
#
#   managed_origin_request_policy_names = []
#   cache_behaviors = [
#     {
#       compress                   = true
#       allowed_methods            = ["GET", "HEAD", "OPTIONS"]
#       cached_methods             = ["GET", "HEAD", "OPTIONS"]
#       viewer_protocol_policy     = var.cloudfront.viewer_protocol
#       cache_policy_name          = "CachingOptimized"
#       origin_request_policy_name = null
#     }
#   ]
#
#   tags = merge(local.default_tags, var.tags, {
#     Name = "${var.project}-cloudfront-${var.environment}"
#   })
# }
