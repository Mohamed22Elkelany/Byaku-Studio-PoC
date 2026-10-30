# tfsec:ignore:aws-s3-encryption-customer-key
# tfsec:ignore:aws-s3-enable-bucket-logging
module "awsconfig_s3_bucket" {
  source = "./modules/s3_bucket"

  name                = "${var.project}-awsconfig-${var.environment}-${data.aws_caller_identity.current.account_id}"
  s3_object_ownership = "BucketOwnerEnforced"
  ignore_public_acls  = true
  force_destroy       = true

  tags = merge(local.default_tags, var.tags)
}

# tfsec:ignore:aws-iam-no-policy-wildcards
module "aws_config_recorder" {
  source = "./modules/awsconfig_recorder"

  name           = "${var.project}-awsconfig-${var.environment}"
  s3_bucket_arn  = module.awsconfig_s3_bucket.bucket_arn
  s3_bucket_name = module.awsconfig_s3_bucket.bucket_id
  tags           = merge(local.default_tags, var.tags)
}
