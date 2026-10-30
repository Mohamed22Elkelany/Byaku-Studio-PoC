variable "name" {
  description = "The name of the budget"
  type        = string
}

variable "type" {
  description = "The type of the budget (e.g., COST, USAGE)"
  type        = string
  default     = "COST"
}

variable "limit_amount" {
  description = "The limit amount for the budget"
  type        = number
}

variable "limit_unit" {
  description = "The unit of the limit (e.g., USD)"
  type        = string
  default     = "USD"
}

variable "time_unit" {
  description = "The time unit for the budget (e.g., MONTHLY)"
  type        = string
}

variable "time_period_start" {
  description = "The start date for the budget time period"
  type        = string
}

variable "cost_filters" {
  description = "A list of cost filters for the budget"
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = []
}

variable "notifications" {
  description = "Map of notification configurations"
  type = map(object({
    comparison_operator        = string
    threshold                  = number
    threshold_type             = string
    notification_type          = string
    subscriber_email_addresses = optional(list(string))
    subscriber_sns_topic_arns  = list(string)
  }))
  default = {}
}

variable "cost_types" {
  description = "Settings for including various cost types in the budget. Defaults to valid values for blended costs."
  type = object({
    include_credit             = optional(bool, true)
    include_discount           = optional(bool, false)
    include_other_subscription = optional(bool, true)
    include_recurring          = optional(bool, true)
    include_refund             = optional(bool, true)
    include_subscription       = optional(bool, true)
    include_support            = optional(bool, true)
    include_tax                = optional(bool, true)
    include_upfront            = optional(bool, true)
    use_blended                = optional(bool, true)
    use_amortized              = optional(bool, false)
  })
  default = {}
}

variable "tags" {
  description = "Tags to be added to the provisioned infrastructure."
  type        = map(string)
  default     = {}
}
