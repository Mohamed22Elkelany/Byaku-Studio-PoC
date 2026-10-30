###########################################################################
# Account trail: the Byaku-Studio-PoC account is not covered by an
# organization trail, so a multi-region management-events trail is created
# here (S3 for retention, CloudWatch Logs for search and alarms).
###########################################################################

# tfsec:ignore:aws-s3-enable-bucket-logging
module "cloudtrail_s3_bucket" {
  source                  = "./modules/s3_bucket"
  name                    = "${var.project}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}"
  s3_object_ownership     = "BucketOwnerEnforced"
  versioning_enabled      = var.cloudtrail_config.s3_bucket.versioning_enabled
  bucket_key_enabled      = var.cloudtrail_config.s3_bucket.bucket_key_enabled
  block_public_acls       = var.cloudtrail_config.s3_bucket.block_public_acls
  block_public_policy     = var.cloudtrail_config.s3_bucket.block_public_policy
  ignore_public_acls      = var.cloudtrail_config.s3_bucket.ignore_public_acls
  restrict_public_buckets = var.cloudtrail_config.s3_bucket.restrict_public_buckets
  force_destroy           = var.cloudtrail_config.s3_bucket.force_destroy

  sse_algorithm       = var.cloudtrail_config.s3_bucket.sse_algorithm
  privileged_services = var.cloudtrail_config.s3_bucket.privileged_services

  tags = merge(local.default_tags, var.tags)
}

# CloudTrail Log Group
module "cloudtrail_log_group" {
  source = "./modules/cloudwatch_log_group"

  name              = "${var.project}-cloudtrail-log-group-${var.environment}"
  log_group_class   = var.cloudtrail_config.log_group.log_group_class
  retention_in_days = var.cloudtrail_config.log_group.retention_in_days

  tags = merge(local.default_tags, var.tags)
}

# CloudTrail Module
module "cloudtrail" {
  source = "./modules/cloudtrail"

  name                  = "${var.project}-cloudtrail-${var.environment}"
  s3_bucket_name        = module.cloudtrail_s3_bucket.bucket_id
  is_multi_region_trail = var.cloudtrail_config.trail.is_multi_region_trail

  enable_logging             = var.cloudtrail_config.trail.enable_logging
  cloud_watch_logs_group_arn = "${module.cloudtrail_log_group.cloudwatch_log_group_arn}:*"

  insight_selector = [
    {
      insight_type = "ApiCallRateInsight"
    }
  ]

  # Management events only. S3/Lambda data events are billed per event; add
  # data_resource entries here if object-level auditing is required.
  event_selector = [
    {
      include_management_events = true
      read_write_type           = "All"
      data_resource             = []
    }
  ]

  tags = merge(local.default_tags, var.tags)

  depends_on = [module.cloudtrail_s3_bucket]
}

# S3 Lifecycle Rules for CloudTrail Logs
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = module.cloudtrail_s3_bucket.bucket_id

  dynamic "rule" {
    for_each = var.cloudtrail_config.s3_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {}

      noncurrent_version_expiration {
        noncurrent_days = rule.value.noncurrent_days
      }
    }
  }
}
