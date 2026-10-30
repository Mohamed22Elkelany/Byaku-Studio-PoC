output "topic_arn" {
  description = "The ARN of the SNS topic"
  value       = try(aws_sns_topic.this[0].arn, null)
}

output "topic_name" {
  description = "The name of the topic"
  value       = try(aws_sns_topic.this[0].name, null)
}

output "topic_id" {
  description = "The ID of the topic"
  value       = try(aws_sns_topic.this[0].id, null)
}

output "topic_owner" {
  description = "The AWS Account ID of the SNS topic owner"
  value       = try(aws_sns_topic.this[0].owner, null)
}

output "topic_policy" {
  description = "The fully-formed AWS policy as JSON"
  value       = try(aws_sns_topic_policy.this[0].policy, null)
}

output "subscriptions" {
  description = "A map of subscription details"
  value = {
    for idx, subscription in aws_sns_topic_subscription.this : idx => {
      arn                            = subscription.arn
      confirmation_was_authenticated = subscription.confirmation_was_authenticated
      owner_id                       = subscription.owner_id
      pending_confirmation           = subscription.pending_confirmation
    }
  }
}

# Additional output for backward compatibility and main terraform access
output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alerts (alias for topic_arn)"
  value       = try(aws_sns_topic.this[0].arn, null)
}
