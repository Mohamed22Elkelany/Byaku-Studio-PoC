
################################################################################
# AWS DB Instance
################################################################################

output "db_instance_address" {
  value       = try(aws_db_instance.this.address, null)
  description = "The hostname of the RDS instance."
}

output "db_instance_arn" {
  value       = try(aws_db_instance.this.arn, null)
  description = "The ARN of the RDS instance."
}

output "db_instance_availability_zone" {
  value       = try(aws_db_instance.this.availability_zone, null)
  description = "The availability zone of the RDS instance."
}

output "db_instance_endpoint" {
  value       = try(aws_db_instance.this.endpoint, null)
  description = "The connection endpoint of the DB instance."
}

output "db_listener_endpoint" {
  value       = try(aws_db_instance.this.listener_endpoint, null)
  description = "Specifies the listener connection endpoint for SQL Server Always On."
}

output "db_instance_engine" {
  value       = try(aws_db_instance.this.engine, null)
  description = "The database engine."
}

output "db_instance_engine_version_actual" {
  value       = try(aws_db_instance.this.engine_version_actual, null)
  description = "The running version of the database."
}

output "db_instance_hosted_zone_id" {
  value       = try(aws_db_instance.this.hosted_zone_id, null)
  description = "The canonical hosted zone ID of the DB instance."
}

output "db_instance_identifier" {
  value       = try(aws_db_instance.this.identifier, null)
  description = "The RDS instance identifier."
}

output "db_instance_resource_id" {
  value       = try(aws_db_instance.this.resource_id, null)
  description = "The RDS Resource ID of this instance."
}

output "db_instance_status" {
  value       = try(aws_db_instance.this.status, null)
  description = "The RDS instance status."
}

output "db_instance_name" {
  value       = try(aws_db_instance.this.db_name, null)
  description = "The database name."
}

output "db_instance_username" {
  value       = try(aws_db_instance.this.username, null)
  sensitive   = true
  description = "The master username for the database."
}

output "db_instance_port" {
  value       = try(aws_db_instance.this.port, null)
  description = "The database port."
}

output "db_instance_ca_cert_identifier" {
  value       = try(aws_db_instance.this.ca_cert_identifier, null)
  description = "Specifies the identifier of the CA certificate for the DB instance."
}

output "db_instance_domain" {
  value       = try(aws_db_instance.this.domain, null)
  description = "The ID of the Directory Service Active Directory domain the instance is joined to."
}

output "db_instance_domain_iam_role_name" {
  value       = try(aws_db_instance.this.domain_iam_role_name, null)
  description = "The name of the IAM role to be used when making API calls to the Directory Service."
}

output "db_instance_master_user_secret_arn" {
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
}

output "db_instance_id" {
  value       = try(aws_db_instance.this.id, null)
  description = "RDS DBI resource ID."
}

output "db_instance_allocated_storage" {
  value       = try(aws_db_instance.this.allocated_storage, null)
  description = "The amount of allocated storage."
}

################################################################################
# Enhanced Monitoring
################################################################################

output "enhanced_monitoring_iam_role_name" {
  description = "The name of the monitoring role"
  value       = try(aws_iam_role.enhanced_monitoring.name, null)
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the monitoring role"
  value       = try(aws_iam_role.enhanced_monitoring.arn, null)
}

################################################################################
# CloudWatch Log Group
################################################################################

output "db_instance_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = aws_cloudwatch_log_group.this
}

output "security_group_id" {
  description = "ID of the security group attached to the instance."
  value       = aws_security_group.this.id
}
