variable "linking_mode" {
  description = "The mode by which findings are aggregated. Valid values are: ALL_REGIONS_EXCEPT_SPECIFIED, SPECIFIED_REGIONS, ALL_REGIONS."
  type        = string
  default     = "SPECIFIED_REGIONS" # Set a sensible default or adjust as per your requirements
}

variable "specified_regions" {
  description = "A list of region names for the finding aggregator."
  type        = list(string)
  default     = null # Use null as default to allow conditional checks in the resource
}

variable "enable_aggregation" {
  description = "whether to enable aggregation or not"
  type        = bool
  default     = false
}

variable "standards_arns" {
  description = "List of ARNs for AWS Security Hub standards to which the account will subscribe."
  type        = list(string)
  default     = []
}