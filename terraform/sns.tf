# SNS Topic for CloudWatch Alarms and Budget notifications
module "cloudwatch_alerts" {
  source = "./modules/sns_topic"

  name = "${var.project}-alerting-topic-${var.environment}"

  enable_cloudwatch_policy = true
  topic_policy_statements = {
    budgets = {
      sid    = "AllowBudgetsToPublish"
      effect = "Allow"
      principals = [{
        type        = "Service"
        identifiers = ["budgets.amazonaws.com"]
      }]
      actions = ["sns:Publish"]
      conditions = [{
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }]
    }
  }

  # Each address receives a confirmation email that must be accepted.
  subscriptions = [
    for email in var.alert_email_endpoints : {
      protocol = "email"
      endpoint = email
    }
  ]

  tags = merge(local.default_tags, var.tags, {
    Name    = "${var.project}-alerting-topic-${var.environment}"
    Purpose = "CloudWatch and Budgets Alerting"
  })
}
