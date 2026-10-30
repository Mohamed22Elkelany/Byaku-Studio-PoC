variable "identifier" {
  type        = string
  description = "The name of the DB instance."
}

variable "engine" {
  type        = string
  description = "The database engine to use."
}

variable "engine_version" {
  type        = string
  description = "The engine version to use."
}

variable "instance_class" {
  type        = string
  description = "The DB instance type."
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gigabytes."
}

variable "max_allocated_storage" {
  type        = number
  default     = 0
  description = "Upper limit for storage autoscaling."
}

variable "storage_throughput" {
  type        = number
  default     = null
  description = "Storage throughput value for gp3 storage type."
}

variable "storage_type" {
  type        = string
  default     = null
  description = "One of standard, gp2, gp3, or io1."
}

variable "allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Allow major version upgrades."
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Allow minor engine upgrades during maintenance window."
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Apply modifications immediately."
}

variable "availability_zone" {
  type        = string
  default     = null
  description = "The Availability Zone of the RDS instance."
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Days to retain backups (0-35)."
}

variable "backup_window" {
  type        = string
  default     = null
  description = "Daily time range for automated backups."
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["general", "error"]
  description = "Log types to export to CloudWatch."
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Copy tags to snapshots."
}

variable "custom_iam_instance_profile" {
  type        = string
  default     = null
  description = "RDS custom IAM instance profile."
}

variable "db_name" {
  type        = string
  default     = null
  description = "Database name to create."
}

variable "delete_automated_backups" {
  type        = bool
  default     = true
  description = "Remove automated backups on deletion."
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Prevent database deletion."
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable IAM database authentication."
}

variable "provisioned_iops" {
  type        = number
  default     = null
  description = "Provisioned IOPS for io1 or gp3."
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN for encryption."
}

variable "maintenance_window" {
  type        = string
  default     = null
  description = "Maintenance window (ddd:hh24:mi-ddd:hh24:mi)."
}

variable "manage_master_user_password" {
  type        = bool
  default     = false
  description = "Let RDS manage password in Secrets Manager."
}

variable "master_user_secret_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key for master user password secret."
}

variable "multi_az" {
  type        = bool
  default     = true
  description = "Enable Multi-AZ deployment."
}

variable "network_type" {
  type        = string
  default     = null
  description = "Network stack type: IPV4 or DUAL."
}

variable "username" {
  type        = string
  description = "Master DB username."
}

variable "password" {
  type        = string
  default     = null
  sensitive   = true
  description = "Master DB password."
}

variable "port" {
  type        = string
  default     = null
  description = "Database port."
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Make instance publicly accessible."
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot on deletion."
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Encrypt storage."
}

variable "timeouts" {
  type        = map(string)
  default     = {}
  description = "Resource management timeouts."
}

variable "timezone" {
  type        = string
  default     = null
  description = "Time zone (SQL Server only)."
}

variable "enable_blue_green_update" {
  type        = bool
  default     = false
  description = "Enable Blue/Green deployments."
}

variable "dedicated_log_volume" {
  type        = bool
  default     = false
  description = "Use dedicated log volume."
}

variable "database_insights_mode" {
  type        = string
  default     = null
  description = "Database Insights mode: standard or advanced."
}

variable "engine_lifecycle_support" {
  type        = string
  default     = null
  description = "Engine lifecycle support type."
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Final snapshot name."
}

variable "ca_cert_identifier" {
  type        = string
  default     = null
  description = "CA certificate identifier."
}

variable "snapshot_identifier" {
  type        = string
  default     = null
  description = "Snapshot ID to restore from."
}

variable "replicate_source_db" {
  type        = string
  default     = null
  description = "Source DB for replica."
}

variable "replica_mode" {
  type        = string
  default     = null
  description = "Replica mode (Oracle only)."
}

variable "s3_import" {
  type = object({
    bucket_name           = string
    bucket_prefix         = optional(string)
    ingestion_role        = string
    source_engine         = string
    source_engine_version = string
  })
  default     = null
  description = "S3 import configuration."
}

variable "restore_to_point_in_time" {
  type = object({
    restore_time                             = optional(string)
    source_db_instance_identifier            = optional(string)
    source_db_instance_automated_backups_arn = optional(string)
    source_dbi_resource_id                   = optional(string)
    use_latest_restorable_time               = optional(bool)
  })
  default     = null
  description = "Point-in-time restore configuration."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "VPC security group IDs."
}

variable "subnet_ids" {
  type        = list(string)
  description = "VPC subnet IDs."
}

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Enable Performance Insights."
}

variable "performance_insights_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key for Performance Insights."
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "Performance Insights retention days."
}

variable "monitoring_interval" {
  type        = number
  default     = 15
  description = "Enhanced Monitoring interval (0,1,5,10,15,30,60)."
}

variable "monitoring_role_permissions_boundary" {
  type        = string
  default     = null
  description = "Permissions boundary for monitoring role."
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key for CloudWatch log encryption."
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  default     = 365
  description = "CloudWatch log retention days."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group."
}

variable "ingress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for resources."
}
