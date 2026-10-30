locals {
  module_name       = "tf-aws/sns-topic"
  module_version    = trimspace(file("${path.module}/RELEASE"))
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
  # Create topic policy from statements
  policy_statements = merge(
    var.topic_policy_statements,
    var.enable_cloudwatch_policy ? {
      cloudwatch = {
        sid    = "AllowCloudWatchAlarmsToPublish"
        effect = "Allow"
        principals = [{
          type        = "Service"
          identifiers = ["cloudwatch.amazonaws.com"]
        }]
        actions = ["sns:Publish"]
        conditions = [{
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values   = [data.aws_caller_identity.current.account_id]
        }]
      }
    } : {}
  )

  # Determine if we should create a policy
  should_create_policy = var.create && var.create_topic_policy && (
    var.topic_policy != null || length(local.policy_statements) > 0
  )
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Generate policy document from statements
data "aws_iam_policy_document" "this" {
  count = var.create && length(local.policy_statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = local.policy_statements
    content {
      sid       = lookup(statement.value, "sid", statement.key)
      effect    = lookup(statement.value, "effect", "Allow")
      actions   = statement.value.actions
      resources = [aws_sns_topic.this[0].arn]

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_sns_topic" "this" {
  count = var.create ? 1 : 0

  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null

  display_name                             = var.display_name
  kms_master_key_id                        = var.kms_master_key_id
  fifo_topic                               = var.fifo_topic
  content_based_deduplication              = var.content_based_deduplication
  archive_policy                           = var.archive_policy
  delivery_policy                          = var.delivery_policy
  tracing_config                           = var.tracing_config
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn
  firehose_success_feedback_role_arn       = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate    = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn       = var.firehose_failure_feedback_role_arn
  http_success_feedback_role_arn           = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate        = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn           = var.http_failure_feedback_role_arn
  lambda_success_feedback_role_arn         = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate      = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn         = var.lambda_failure_feedback_role_arn
  sqs_success_feedback_role_arn            = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate         = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn            = var.sqs_failure_feedback_role_arn

  tags = merge(local.default_tags, var.tags)
}

resource "aws_sns_topic_policy" "this" {
  count = local.should_create_policy ? 1 : 0

  arn    = aws_sns_topic.this[0].arn
  policy = var.topic_policy != null ? var.topic_policy : data.aws_iam_policy_document.this[0].json
}

resource "aws_sns_topic_subscription" "this" {
  count = var.create ? length(var.subscriptions) : 0

  topic_arn                       = aws_sns_topic.this[0].arn
  protocol                        = var.subscriptions[count.index].protocol
  endpoint                        = var.subscriptions[count.index].endpoint
  endpoint_auto_confirms          = lookup(var.subscriptions[count.index], "endpoint_auto_confirms", null)
  confirmation_timeout_in_minutes = lookup(var.subscriptions[count.index], "confirmation_timeout_in_minutes", null)
  raw_message_delivery            = lookup(var.subscriptions[count.index], "raw_message_delivery", null)
  filter_policy                   = lookup(var.subscriptions[count.index], "filter_policy", null)
  filter_policy_scope             = lookup(var.subscriptions[count.index], "filter_policy_scope", null)
  delivery_policy                 = lookup(var.subscriptions[count.index], "delivery_policy", null)
  redrive_policy                  = lookup(var.subscriptions[count.index], "redrive_policy", null)
}
