output "finding_aggregator_account_id" {
  description = "The AWS Account ID where the Security Hub finding aggregator is located."
  value       = aws_securityhub_account.this.id
}

output "securityhub_hub_arn" {
  description = "The ARN of the SecurityHub Hub created in the account."
  value       = aws_securityhub_account.this.arn # Adjust if a different resource or attribute is needed.
}
