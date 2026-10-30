variable "alarm_name" {
  description = "CloudWatch alarm names"
  type        = string
}

variable "metric_name" {
  description = "Metric names"
  type        = string
}

variable "namespace" {
  description = "Metric namespaces"
  type        = string
}

variable "threshold" {
  description = "Thresholds for the metrics"
  type        = number
}

variable "comparison_operator" {
  description = "Comparison operators for the alarms"
  type        = string
}

variable "evaluation_period" {
  description = "Evaluation periods for the alarms"
  type        = number
}

variable "sns_topic_arn" {
  description = "SNS topic ARNs for the alarms"
  type        = string
}

variable "statistic" {
  description = "Statistics for the alarms"
  type        = string
}

variable "dimensions" {
  description = "Dimensions for the alarms"
  type        = map(string)
}

variable "alarm_description" {
  description = "Descriptions for the alarms"
  type        = string
}

variable "metric_query" {
  description = "Enables you to create an alarm based on a metric math expression. You may specify at most 20."
  type        = any
  default     = []
}

variable "period" {
  description = "Period for the alarms in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to be added to the provisioned infrastructure."
  type        = map(string)
  default     = {}
}
