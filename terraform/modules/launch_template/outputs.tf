output "launch_template_id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template."
  value       = aws_launch_template.this.latest_version
}

output "ec2_instance_iam_profile_role" {
  description = " The IAM Role for the EC2 Instance launch template"
  value       = aws_iam_role.this.name
}