variable "name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "force_destroy" {
  description = "Allows deletion of a non-empty S3 bucket by first removing all objects in the bucket."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enables or disables versioning for the S3 bucket."
  type        = bool
  default     = true
}

variable "object_lock_configuration" {
  description = <<-EOT
    Configures object lock for the bucket, enabling a `write once, read many` (WORM) model to 
    prevent objects from being deleted or overwritten for a specified period or indefinitely.
  EOT
  type = object({
    mode  = string # Valid values: GOVERNANCE and COMPLIANCE
    days  = number
    years = number
  })
  default = null
}

variable "bucket_key_enabled" {
  description = "Determines whether Amazon S3 Bucket Keys are used for SSE-KMS encryption."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values: `AES256`, `aws:kms`."
  type        = string
  default     = "AES256"
  nullable    = false
}

variable "kms_master_key_arn" {
  description = <<-EOT
    The ARN of the AWS KMS master key for `SSE-KMS` encryption.
    Required if `sse_algorithm` is set to `aws:kms`. Defaults to `aws/s3` if absent.
  EOT
  type        = string
  default     = null
}

variable "access_logs" {
  description = "Configuration for S3 bucket access logging."
  type = object({
    bucket_name = string
    prefix      = string
  })
  default = null
}

variable "cors_configuration" {
  description = "Configures Cross-Origin Resource Sharing (CORS) for the S3 bucket."
  type = list(object({
    id              = optional(string)
    allowed_headers = optional(list(string))
    allowed_methods = optional(list(string))
    allowed_origins = optional(list(string))
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default  = []
  nullable = false
}

variable "block_public_acls" {
  description = "Controls whether new public access control lists (ACLs) are blocked."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Controls whether new public bucket policies are blocked."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Controls whether public ACLs on the bucket are ignored."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restricts the ability to make the bucket public."
  type        = bool
  default     = true
}

variable "s3_object_ownership" {
  description = <<-EOT
    Specifies S3 object ownership control. Valid values: `ObjectWriter`, `BucketOwnerPreferred`, `BucketOwnerEnforced`.
    More details: https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html#object-ownership-overview
  EOT
  type        = string
  default     = "ObjectWriter"
  nullable    = false
}

variable "privileged_services" {
  description = "Defines access permissions for privileged services interacting with the bucket."
  type = list(object({
    principal_type        = string
    principal_identifiers = string
    actions               = list(string)
    resources             = optional(list(string))
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default = []
}

variable "tags" {
  description = "Tags to assign to the S3 bucket and its resources."
  type        = map(string)
  default     = {}
}
