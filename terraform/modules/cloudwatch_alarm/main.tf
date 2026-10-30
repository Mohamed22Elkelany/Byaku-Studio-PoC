locals {
  module_name       = "tf-aws/cloudwatch-alarm"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {

  alarm_name          = var.alarm_name
  alarm_description   = var.alarm_description
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_period
  threshold           = var.threshold

  # If no metric_query provided, use regular metric configuration
  metric_name = length(var.metric_query) == 0 ? var.metric_name : null
  namespace   = length(var.metric_query) == 0 ? var.namespace : null
  statistic   = length(var.metric_query) == 0 ? var.statistic : null
  period      = length(var.metric_query) == 0 ? var.period : null
  dimensions  = length(var.metric_query) == 0 ? var.dimensions : null

  dynamic "metric_query" {
    for_each = var.metric_query
    content {
      # id = "m${metric_query.key + 1}"
      id          = lookup(metric_query.value, "id")
      return_data = lookup(metric_query.value, "return_data", true)
      expression  = lookup(metric_query.value, "expression", null)
      # period      = lookup(metric_query.value, "period", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          stat        = lookup(metric.value, "statistic")
          period      = lookup(metric.value, "period")
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }

  alarm_actions = [var.sns_topic_arn]

  tags = merge(local.default_tags, var.tags)
}