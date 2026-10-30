module "budget" {
  source = "./modules/budget"

  for_each = var.budgets

  name              = "${var.project}-${each.value.name}-${var.environment}"
  type              = each.value.type
  limit_amount      = each.value.limit_amount
  limit_unit        = each.value.limit_unit
  time_unit         = each.value.time_unit
  time_period_start = each.value.time_period_start
  cost_filters      = each.value.cost_filters
  cost_types        = each.value.cost_types

  # Every notification is delivered to the alerting topic in addition to any
  # subscribers configured per budget.
  notifications = {
    for key, notification in each.value.notifications : key => merge(notification, {
      subscriber_sns_topic_arns = distinct(concat(notification.subscriber_sns_topic_arns, [module.cloudwatch_alerts.topic_arn]))
    })
  }

  tags = merge(local.default_tags, var.tags)

  depends_on = [module.cloudwatch_alerts]
}
