variable "name" {
  description = "The name of the cloudtrail."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket designated for publishing log files."
  type        = string
}

variable "is_multi_region_trail" {
  description = "Whether the trail is created in the current region or in all regions."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enables logging for the trail."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Specifies whether log file integrity validation is enabled."
  type        = bool
  default     = true
}

variable "sns_topic_name" {
  description = "Name of the Amazon SNS topic defined for notification of log file delivery."
  type        = string
  default     = null
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files."
  type        = bool
  default     = true
}

variable "cloud_watch_logs_group_arn" {
  description = "Log group name using an ARN that represents the log group to which CloudTrail logs will be delivered."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN to use to encrypt the logs delivered by CloudTrail."
  type        = string
  default     = null
}

variable "is_organization_trail" {
  description = "Whether the trail is an AWS Organizations trail."
  type        = bool
  default     = false
}

variable "insight_selector" {
  description = "Specifies an insight selector for type of insights to log on a trail."
  type = list(object({
    insight_type = string
  }))
  default = []
}

variable "event_selector" {
  description = "Specifies an event selector for enabling data event logging."
  type = list(object({
    include_management_events        = bool
    exclude_management_event_sources = optional(set(string))
    read_write_type                  = string

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))
  default = []
}

variable "advanced_event_selector" {
  description = "Specifies an advanced event selector for enabling data event logging (Conflicts with `event_selector`)."
  type = list(object({
    name = optional(string)
    field_selector = list(object({
      field           = string
      ends_with       = optional(list(string))
      not_ends_with   = optional(list(string))
      equals          = optional(list(string))
      not_equals      = optional(list(string))
      starts_with     = optional(list(string))
      not_starts_with = optional(list(string))
    }))
  }))
  default = []
}

variable "tags" {
  description = "Tags to be added to the provisioned infrastructure."
  type        = map(string)
  default     = {}
}