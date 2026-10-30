variable "name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = null
}

variable "launch_template_id" {
  description = "ID of the launch template to use for the ASG"
  type        = string
  default     = null
}

variable "launch_template_version" {
  description = "Exact launch template version to use for the ASG"
  type        = number
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
  default     = null
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
  default     = null
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  type        = number
  default     = null
}

variable "vpc_zone_identifier" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
  default     = []
}

variable "target_group_arns" {
  description = "List of target group ARNs to associate with the ASG"
  type        = list(string)
  default     = []
}

variable "health_check_grace_period" {
  description = "The period after the instance comes into service before checking its health."
  type        = number
  default     = 300 # You can set a default or remove it to make the variable required
}

variable "health_check_type" {
  description = "The type of health check being performed. Options are EC2 or ELB."
  type        = string
  default     = "ELB" # Default to ELB, change as necessary or remove for required input
}

variable "default_instance_warmup" {
  description = "The time period during which the instance is in warm-up state under Auto Scaling."
  type        = number
  default     = 15 # Default value, adjust as necessary
}

variable "metrics_granularity" {
  description = "Granularity to associate with the metrics to collect. ."
  type        = string
  default     = "1Minute"
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
