variable "enabled" {
  description = "Whether to create the ECR repository."
  type        = bool
  default     = false
}

variable "repository_name" {
  description = "List of ECR repository names"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "image_scanning" {
  description = "Enable or disable image scanning"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "encryption_type" {
  description = "Repository encryption type: AES256 or KMS."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN used when encryption_type is KMS (defaults to the AWS managed key when null)."
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "Optional ECR lifecycle policy document (JSON)."
  type        = string
  default     = null
}
