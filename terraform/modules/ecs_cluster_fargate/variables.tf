# ECS Cluster name
variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

# Capacity Providers for the ECS cluster
variable "capacity_providers" {
  description = "List of capacity providers (FARGATE and/or FARGATE_SPOT)"
  type        = list(string)
  default     = ["FARGATE"]
}

# Default Capacity Provider Strategy
variable "default_capacity_provider" {
  description = "The default capacity provider for the ECS cluster"
  type        = string
  default     = "FARGATE"
}

variable "default_capacity_provider_weight" {
  description = "The weight for the default capacity provider strategy"
  type        = number
  default     = 1
}

variable "default_capacity_provider_base" {
  description = "The base value for the default capacity provider strategy"
  type        = number
  default     = 0
}

# Other variables (already defined)
variable "configuration_enabled" {
  description = "Enable or disable configuration for the ECS cluster"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = ""
}

variable "cloud_watch_encryption_enabled" {
  description = "Enable encryption for CloudWatch logs"
  type        = bool
  default     = false
}

variable "cloud_watch_log_group_name" {
  description = "The CloudWatch log group name"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "The S3 bucket name for logs"
  type        = string
  default     = ""
}

variable "s3_bucket_encryption_enabled" {
  description = "Enable encryption for S3 bucket logs"
  type        = bool
  default     = false
}

variable "s3_key_prefix" {
  description = "S3 key prefix for log storage"
  type        = string
  default     = ""
}

variable "logging" {
  description = "Logging configuration for execute command"
  type        = string
  default     = "NONE"
}

variable "fargate_ephemeral_storage_kms_key_id" {
  description = "KMS key ID for ephemeral storage encryption on Fargate"
  type        = string
  default     = ""
}

variable "managed_storage_kms_key_id" {
  description = "KMS key ID for managed storage encryption"
  type        = string
  default     = ""
}

variable "service_connect_enabled" {
  description = "Enable or disable Service Connect"
  type        = bool
  default     = false
}

variable "service_connect_namespace" {
  description = "ARN of the Service Connect namespace"
  type        = string
  default     = ""
}

variable "settings" {
  description = "Cluster settings (such as containerInsights)"
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to the cluster"
  type        = map(string)
  default     = {}
}
