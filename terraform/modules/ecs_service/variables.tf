variable "name" {
  description = "The name of the ECS service"
  type        = string
}

variable "cluster" {
  description = "The ECS cluster to run the service in"
  type        = string
}

variable "task_definition" {
  description = "The task definition to use for the service"
  type        = string
}

variable "desired_count" {
  description = "The number of desired tasks"
  type        = number
}

variable "launch_type" {
  description = "The launch type for the service (FARGATE, EC2)"
  type        = string
}

variable "use_capacity_provider" {
  type    = bool
  default = false
}

variable "capacity_provider_name" {
  type    = string
  default = null
}


variable "platform_version" {
  description = "The platform version for the service"
  type        = string
  default     = null
}

variable "deployment_maximum_percent" {
  description = "Upper limit on the number of running tasks during a deployment"
  type        = number
  default     = 200
}

variable "placement_strategy" {
  description = "List of placement strategy for ECS service"
  type = list(object({
    type  = string # spread, binpack, random
    field = optional(string)
  }))
  default = []
}

variable "enable_circuit_breaker" {
  type        = bool
  default     = true
  description = "Enable ECS deployment circuit breaker."
}

variable "circuit_breaker_rollback" {
  type        = bool
  default     = true
  description = "Auto-rollback on failed deployment."
}

variable "enable_autoscaling" {
  description = "Enable ECS service auto scaling"
  type        = bool
  default     = false
}

variable "autoscaling" {
  description = "Auto scaling configuration for ECS service"
  type = object({
    min_capacity = number
    max_capacity = number

    target_tracking = list(object({
      name         = string
      metric_type  = string # cpu | memory | alb
      target_value = number

      scale_in_cooldown  = number
      scale_out_cooldown = number

      # Only required for ALB
      alb_target_group_arn = optional(string)
    }))
  })
  default = null
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks during a deployment"
  type        = number
  default     = 100
}

variable "subnets" {
  description = "The subnets for the service"
  type        = list(string)
  default     = null
}

variable "security_groups" {
  description = "The security groups for the service"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP"
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "The ARN of the target group for the service's load balancer"
  type        = string
  default     = ""
}

variable "container_name" {
  description = "The container name to use for the load balancer"
  type        = string
}

variable "container_port" {
  description = "The container port to use for the load balancer"
  type        = number
  default     = null
}

variable "enable_execute_command" {
  description = "value"
  type        = bool
  default     = true
}

variable "service_connect_port_name" {
  description = "The name of the port that Service Connect will use."
  type        = string
  default     = ""
}

variable "service_connect_discovery_name" {
  description = "The discovery name for the service in Service Connect."
  type        = string
  default     = ""
}

variable "service_connect_client_aliases" {
  description = "List of client aliases for Service Connect."
  type        = list(string)
  default     = []
}
variable "enable_service_connect" {
  description = "Whether to enable Service Connect for this service."
  type        = bool
  default     = false
}

variable "service_connect_namespace" {
  description = "The namespace for ECS Service Connect."
  type        = string
  default     = ""
}

variable "service_connect_log_driver" {
  description = "Log driver to use for the Service Connect configuration."
  type        = string
  default     = "awslogs"
}

variable "service_connect_log_options" {
  description = "Log configuration options for the Service Connect configuration."
  type        = map(string)
  default     = {}
}

variable "service_connect_log_secret_options" {
  description = "Secrets to pass to the log configuration for Service Connect."
  type = list(object({
    name       = string
    value_from = string
  }))
  default = []
}

variable "services" {
  description = "List of Service Connect service configurations."
  type = list(object({
    discovery_name        = string
    ingress_port_override = optional(number)
    port_name             = string
    # timeout = object({
    #   idle_timeout_seconds        = number
    #   per_request_timeout_seconds = number
    # })
    client_aliases = list(object({
      dns_name = string
      port     = number
    }))
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the ECS service"
  type        = map(string)
  default     = {}
}
