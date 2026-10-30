data "aws_partition" "current" {}

resource "aws_db_instance" "this" {
  identifier = lower(var.identifier)
  db_name    = var.snapshot_identifier != null || var.replicate_source_db != null ? null : var.db_name

  # Engine Configuration (not needed for replicas)
  engine         = var.replicate_source_db != null ? null : var.engine
  engine_version = var.engine_version
  port           = var.port

  lifecycle {
    # snapshot_identifier is only used at creation; changing it later must never
    # replace a restored database.
    ignore_changes = [identifier, snapshot_identifier]
  }

  # Instance Configuration
  instance_class        = var.instance_class
  allocated_storage     = var.replicate_source_db != null ? null : var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  multi_az              = var.multi_az

  # Storage Configuration
  storage_type         = var.storage_type
  storage_encrypted    = var.storage_encrypted
  storage_throughput   = var.storage_throughput
  iops                 = var.provisioned_iops
  dedicated_log_volume = var.dedicated_log_volume

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = var.publicly_accessible
  network_type           = var.network_type
  availability_zone      = var.availability_zone

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.this.name
  option_group_name    = aws_db_option_group.this.name

  # Credentials (not needed for replicas or snapshots)
  username = var.replicate_source_db != null || var.snapshot_identifier != null ? null : var.username
  password = var.replicate_source_db != null || var.snapshot_identifier != null || var.manage_master_user_password ? null : var.password
  # A snapshot restore can switch the master password to an RDS-managed Secrets
  # Manager secret (the snapshot's password is replaced); replicas inherit it.
  manage_master_user_password   = var.replicate_source_db != null ? null : (var.manage_master_user_password ? true : null)
  master_user_secret_kms_key_id = var.manage_master_user_password && var.replicate_source_db == null ? var.master_user_secret_kms_key_id : null

  # Encryption
  kms_key_id = var.kms_key_id

  # Maintenance and Updates
  apply_immediately           = var.apply_immediately
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  maintenance_window          = var.maintenance_window

  # Backup Configuration
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  delete_automated_backups  = var.delete_automated_backups
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  # Protection
  deletion_protection = var.deletion_protection

  # IAM and Security
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  custom_iam_instance_profile         = var.custom_iam_instance_profile
  ca_cert_identifier                  = var.ca_cert_identifier

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  # Database Insights (newer feature)
  database_insights_mode = var.database_insights_mode

  # Enhanced Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring.arn : null

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Lifecycle Support
  engine_lifecycle_support = var.engine_lifecycle_support

  # Snapshot/Replica Configuration
  snapshot_identifier = var.snapshot_identifier
  replicate_source_db = var.replicate_source_db
  replica_mode        = var.replicate_source_db != null ? var.replica_mode : null

  # S3 Import Configuration
  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []
    content {
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = s3_import.value.ingestion_role
      source_engine         = s3_import.value.source_engine
      source_engine_version = s3_import.value.source_engine_version
    }
  }

  # Point-in-Time Restore Configuration
  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [var.restore_to_point_in_time] : []
    content {
      restore_time                             = lookup(restore_to_point_in_time.value, "restore_time", null)
      source_db_instance_identifier            = lookup(restore_to_point_in_time.value, "source_db_instance_identifier", null)
      source_db_instance_automated_backups_arn = lookup(restore_to_point_in_time.value, "source_db_instance_automated_backups_arn", null)
      source_dbi_resource_id                   = lookup(restore_to_point_in_time.value, "source_dbi_resource_id", null)
      use_latest_restorable_time               = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
    }
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }

  # Blue/Green Deployment for low-downtime updates
  blue_green_update {
    enabled = var.enable_blue_green_update
  }

  tags = merge(local.default_tags, var.tags)

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_db_option_group" "this" {

  name_prefix          = "${lower(var.identifier)}-og-"
  engine_name          = var.engine
  major_engine_version = local.engine_major_version

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "this" {

  name_prefix = "${lower(var.identifier)}-pg-"
  family      = local.engine_family

  lifecycle {
    create_before_destroy = true
  }
}
