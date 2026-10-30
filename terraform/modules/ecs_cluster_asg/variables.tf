variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable Container Insights or Not"
  type        = bool
  default     = true

}
variable "auto_scaling_group_arn" {
  description = "ARN of the Autoscaling group of the ECS Cluster"
  type        = string
  default     = null
}

variable "create_capacity_provider" {
  description = "Whether to create and attach an EC2-backed ECS capacity provider"
  type        = bool
  default     = true
}

variable "protect_from_scale_in" {
  description = "Wether to enable Scale In protection or Not"
  type        = bool
  default     = false
}

variable "enable_managed_scaling" {
  description = "Wether to enable Managed Scaling on ECS or Not"
  type        = bool
  default     = false
}

variable "maximum_scaling_step_size" {
  description = "Maximum step adjustment size. A number between 1 and 10,000."
  type        = number
  default     = 2
}

variable "minimum_scaling_step_size" {
  description = "Minimum step adjustment size. A number between 1 and 10,000."
  type        = number
  default     = 1
}

variable "asg_target_capacity_utilization" {
  description = "Target utilization for the capacity provider. A number between 1 and 100."
  type        = number
  default     = 100
}

variable "enable_default_capacity_provider" {
  description = "Enable default capacity provider for ecs or not"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the cluster"
  type        = map(string)
  default     = {}
}
