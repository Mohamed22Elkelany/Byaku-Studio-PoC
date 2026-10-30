variable "secret_name" {
  description = "The name of the secret in AWS Secrets Manager"
  type        = string
}

variable "secret_description" {
  description = "Description for the secret in AWS Secrets Manager"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "Optional KMS key ID or ARN used to encrypt the secret"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Number of days Secrets Manager waits before deleting the secret"
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30
    error_message = "recovery_window_in_days must be between 7 and 30."
  }
}

variable "create_secret_version" {
  description = "Whether Terraform creates and manages an initial secret version"
  type        = bool
  default     = true
}

variable "secret_values" {
  description = "Map of values to store as a JSON secret string"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "secret_string" {
  description = "Raw secret string to store. When set, this overrides secret_values."
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to the secret"
  type        = map(string)
  default     = {}
}
