output "cloudtrail_id" {
  description = "The ID of the trail. (Name for provider < v5, ARN for provider >= v5)."
  value       = aws_cloudtrail.this.id
}

output "cloudtrail_arn" {
  description = "The Amazon Resource Name of the trail"
  value       = aws_cloudtrail.this.arn
}