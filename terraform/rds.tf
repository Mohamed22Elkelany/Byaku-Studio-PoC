# RDS PostgreSQL (core "byaku" and admin "byaku_admin" stores), created empty
# with the default settings below (no snapshot restore); the db-migrate and
# admin-db-migrate tasks create the schemas.
#
# Master passwords are RDS-managed Secrets Manager secrets (manage_master_user_password),
# encrypted with the application secrets key. Automatic rotation (RDS default: every
# 7 days) is disabled because the application DATABASE_URL secrets embed the
# credentials and would break on rotation. Terraform has no argument for rotation
# on RDS-owned secrets, so it was disabled once per secret and Terraform does not
# re-enable it:
#   aws secretsmanager cancel-rotate-secret --secret-id <rds_master_user_secret_arns value>
# Check: aws secretsmanager describe-secret --secret-id <arn> --query RotationEnabled
# Repeat for any newly created instance.

data "aws_iam_policy_document" "kms_database" {
  statement {
    sid       = "AccountAdministration"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "database" {
  description             = "${local.name} RDS storage and snapshots"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_database.json
}

resource "aws_kms_alias" "database" {
  name          = "alias/${local.name}-database"
  target_key_id = aws_kms_key.database.key_id
}

module "rds" {
  for_each = var.db_instances
  source   = "./modules/rds"

  # General Configuration
  identifier = coalesce(each.value.db_identifier, "${local.name}-${each.key}")
  db_name    = each.value.db_name

  # Database Engine Configuration
  engine                   = each.value.engine
  engine_version           = each.value.engine_version
  engine_lifecycle_support = each.value.engine_lifecycle_support

  # Instance Configuration
  instance_class        = each.value.instance_class
  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  multi_az              = each.value.multi_az

  # Storage Configuration
  storage_type       = each.value.storage_type
  storage_encrypted  = each.value.storage_encrypted
  storage_throughput = each.value.storage_throughput
  provisioned_iops   = each.value.provisioned_iops
  kms_key_id         = aws_kms_key.database.arn

  # Credentials: RDS-managed master password in Secrets Manager.
  username                      = each.value.db_username
  manage_master_user_password   = each.value.manage_master_user_password
  master_user_secret_kms_key_id = aws_kms_key.secrets.arn
  password                      = null

  # Maintenance and Updates
  apply_immediately           = each.value.apply_immediately
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  maintenance_window          = each.value.maintenance_window

  # Backup Configuration
  backup_retention_period   = each.value.backup_retention_period
  backup_window             = each.value.backup_window
  copy_tags_to_snapshot     = each.value.copy_tags_to_snapshot
  delete_automated_backups  = each.value.delete_automated_backups
  skip_final_snapshot       = each.value.skip_final_snapshot
  final_snapshot_identifier = "${coalesce(each.value.db_identifier, "${local.name}-${each.key}")}-final"

  # Network Configuration: private "data" tier subnets.
  subnet_ids          = module.vpc.private_subnet_ids_by_tier["data"]
  vpc_id              = module.vpc.vpc_id
  publicly_accessible = false

  # PostgreSQL only from the ECS services that use this store.
  ingress_rules = [
    for svc in each.value.allowed_services : {
      description     = "PostgreSQL from ${local.name}-${svc}"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [aws_security_group.app[svc].id]
    }
  ]
  egress_rules = []

  # Protection
  deletion_protection = each.value.deletion_protection

  # IAM and Security
  iam_database_authentication_enabled = false
  ca_cert_identifier                  = "rds-ca-rsa2048-g1"

  # Performance Insights / monitoring
  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = each.value.performance_insights_enabled ? aws_kms_key.database.arn : null
  monitoring_interval                   = each.value.monitoring_interval

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  timeouts = { create = "90m", update = "90m", delete = "60m" }

  tags = merge(local.default_tags, var.tags, {
    DatabaseEngine = each.value.engine
    DatabaseName   = each.key
  })
}
