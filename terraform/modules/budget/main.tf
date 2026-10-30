locals {
  module_name       = "tf-aws/budget"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_budgets_budget" "main" {
  name              = var.name
  budget_type       = var.type
  limit_amount      = var.limit_amount
  limit_unit        = var.limit_unit
  time_unit         = var.time_unit
  time_period_start = var.time_period_start

  dynamic "cost_filter" {
    for_each = toset(var.cost_filters)
    content {
      name   = cost_filter.value.name
      values = cost_filter.value.values
    }
  }

  dynamic "notification" {
    for_each = var.notifications
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                  = notification.value.threshold
      threshold_type             = notification.value.threshold_type
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses
      subscriber_sns_topic_arns  = notification.value.subscriber_sns_topic_arns
    }
  }

  dynamic "cost_types" {
    for_each = var.cost_types != {} ? [var.cost_types] : []
    content {
      include_credit             = lookup(cost_types.value, "include_credit", true)
      include_discount           = lookup(cost_types.value, "include_discount", false) # Set to false
      include_other_subscription = lookup(cost_types.value, "include_other_subscription", true)
      include_recurring          = lookup(cost_types.value, "include_recurring", true)
      include_refund             = lookup(cost_types.value, "include_refund", true)
      include_subscription       = lookup(cost_types.value, "include_subscription", true)
      include_support            = lookup(cost_types.value, "include_support", true)
      include_tax                = lookup(cost_types.value, "include_tax", true)
      include_upfront            = lookup(cost_types.value, "include_upfront", true)
      use_blended                = lookup(cost_types.value, "use_blended", true)
      use_amortized              = lookup(cost_types.value, "use_amortized", false) # Set to false
    }
  }

  tags = merge(local.default_tags, var.tags)
}
