locals {
  module_name       = "tf-aws/s3-bucket"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_s3_bucket" "this" {
  bucket              = var.name
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_configuration != null

  tags = merge(local.default_tags, var.tags)
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.object_lock_configuration != null ? 1 : 0

  bucket              = aws_s3_bucket.this.id
  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = var.object_lock_configuration.days
      years = var.object_lock_configuration.years
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.versioning_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = var.bucket_key_enabled

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_arn
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = var.access_logs != null ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = var.access_logs.bucket_name
  target_prefix = var.access_logs.prefix
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count = try(length(var.cors_configuration), 0) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_configuration

    content {
      id              = cors_rule.value.id
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  # count = var.block_public_access == false ? 0 : 1
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "default" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.s3_object_ownership
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = length(var.privileged_services) > 0 ? 1 : 0

  bucket     = aws_s3_bucket.this.id
  policy     = data.aws_iam_policy_document.bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.default]
}

data "aws_iam_policy_document" "bucket_policy" {

  dynamic "statement" {
    for_each = var.privileged_services

    content {
      sid     = "AllowPrivilegedPrincipal[${statement.key}]"
      actions = statement.value.actions
      resources = [
        for resource in statement.value.resources :
        "${aws_s3_bucket.this.arn}${resource}"
      ]

      dynamic "condition" {
        for_each = statement.value.conditions != null ? statement.value.conditions : []
        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }

      principals {
        type        = statement.value.principal_type
        identifiers = [statement.value.principal_identifiers]
      }
    }
  }
}
