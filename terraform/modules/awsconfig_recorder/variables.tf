variable "name" {
  description = "AWS Config recorder name"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The S3 bucket ARN to store the logs int."
  type        = string
}

variable "s3_bucket_name" {
  description = "The S3 bucket id to store the logs int."
  type        = string
}

variable "all_supported" {
  description = "Specifies whether AWS Config records configuration changes for every supported type of regional resource."
  type        = bool
  default     = true
}

variable "excluded_resource_types" {
  description = "List of AWS resource types to exclude from recording, if any."
  type        = list(string)
  default     = null # Default as null allows the dynamic block to evaluate properly.
}

variable "recording_strategy" {
  description = "Defines the strategy of recording used, should be either 'EXCLUSION_BY_RESOURCE_TYPES' or another valid strategy if applicable."
  type        = string
  default     = null # Default as null, which makes the dynamic block for strategy optional.
}

variable "recording_frequency" {
  description = "Specifies the frequency with which AWS Config records configuration changes."
  type        = string
  default     = "CONTINUOUS" # CONTINUOUS or DAILY
}

variable "tags" {
  description = "Tags to be added to the provisioned infrastructure."
  type        = map(string)
  default     = {}
}