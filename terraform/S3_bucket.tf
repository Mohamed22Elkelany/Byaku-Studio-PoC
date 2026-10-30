###########################################################################
# OUT OF SCOPE (commented out): S3 storage (media bucket) - phase 2. Uncomment together with cloudfront.tf if the CDN is needed.
###########################################################################

# module "s3_bucket" {
#   source = "./modules/s3_bucket"
#   name   = "${var.project}-media-files-bucket-${var.environment}"
#   tags   = merge(local.default_tags, var.tags)
# }
#
# module "thanos_s3_bucket" {
#   source = "./modules/s3_bucket"
#   name   = "${var.project}-thanos-${var.environment}"
#   tags   = merge(local.default_tags, var.tags)
# }
#
#
#
# resource "aws_s3_bucket_policy" "this" {
#   count  = var.cloudfront.enabled ? 1 : 0
#   bucket = module.s3_bucket.bucket_id
#
#   policy = jsonencode({
#     "Version" = "2012-10-17",
#     "Id"      = "PolicyForCloudFrontPrivateContent",
#     "Statement" = [
#       {
#         "Sid"    = "AllowCloudFrontServicePrincipal",
#         "Effect" = "Allow",
#         "Principal" = {
#           "Service" = "cloudfront.amazonaws.com"
#         },
#         "Action"   = "s3:GetObject",
#         "Resource" = "arn:aws:s3:::${module.s3_bucket.bucket_id}/*",
#         "Condition" = {
#           "StringEquals" = {
#             "AWS:SourceArn" = module.cloudfront[0].distribution_arn
#           }
#         }
#       }
#     ]
#   })
# }
