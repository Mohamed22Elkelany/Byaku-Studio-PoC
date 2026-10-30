###########################################################################
# OUT OF SCOPE (commented out): dashboards - phase 2, once RDS and the ECS
# services exist.
###########################################################################

# module "cloudwatch_environment_dashboard" {
#   source = "./modules/cloudwatch_dashboard"

#   name = "${var.project}-dashboard-${var.environment}"
#   dashboard_body = templatefile("./dashboards/environment_dashboard.json.tftpl", {
#     environment                = var.environment
#     cloudwatch_agent_namespace = var.CloudWatch_dashboard.cloudwatch_agent_namespace
#     rds_name                   = module.rds.db_instance_identifier
#     project                    = var.project
#     region                     = var.aws_region
#     secondary_region           = var.secondary_region
#     ALB_name                   = regex("loadbalancer/(.+)", module.alb.load_balancer_arn)[0]
#     target_group               = regex("targetgroup/.*", module.application_target_group.target_group_arn)
#   })
# }

# module "cloudwatch_common_dashboard" {
#   source = "./modules/cloudwatch_dashboard"

#   name = "${var.project}-common-dashboard-${var.environment}"
#   dashboard_body = templatefile("dashboards/common_dashboard.json.tftpl", {
#     CloudTrail_log_group_name = module.cloudtrail_log_group.cloudwatch_log_group_arn
#     region                    = var.aws_region
#     flow_logs_log_group_name  = regex("log-group:(.*)", module.vpc.flow_logs_log_group_name)[0]
#   })
# }

locals {
  # Baseline alarms for the in-scope services. Extra alarms can be added per
  # environment through var.cloudwatch_alarms.
  baseline_alarms = [
    {
      name                = "alb-5xx-errors"
      metric_name         = "HTTPCode_ELB_5XX_Count"
      namespace           = "AWS/ApplicationELB"
      threshold           = 10
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      statistic           = "Sum"
      period              = 300
      dimensions          = { LoadBalancer = regex("loadbalancer/(.+)$", module.alb.load_balancer_arn)[0] }
      description         = "ALB 5xx errors alarm"
      sns_topic_arn       = null
    },
    {
      name                = "waf-blocked-requests"
      metric_name         = "BlockedRequests"
      namespace           = "AWS/WAFV2"
      threshold           = 100
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      statistic           = "Sum"
      period              = 300
      dimensions = {
        WebACL = module.waf.web_acl_name
        Region = var.aws_region
        Rule   = "ALL"
      }
      description   = "WAF blocked requests alarm"
      sns_topic_arn = null
    }
  ]

  cloudwatch_alarms = { for alarm in concat(local.baseline_alarms, var.cloudwatch_alarms) : alarm.name => alarm }
}

module "cloudwatch_alarms" {
  for_each = local.cloudwatch_alarms

  source = "./modules/cloudwatch_alarm"

  alarm_name          = "${var.project}-${each.key}-alarm-${var.environment}"
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison_operator
  evaluation_period   = each.value.evaluation_periods
  period              = each.value.period
  sns_topic_arn       = coalesce(each.value.sns_topic_arn, module.cloudwatch_alerts.topic_arn)
  statistic           = each.value.statistic
  dimensions          = each.value.dimensions
  alarm_description   = each.value.description
  tags                = merge(local.default_tags, var.tags)
}
