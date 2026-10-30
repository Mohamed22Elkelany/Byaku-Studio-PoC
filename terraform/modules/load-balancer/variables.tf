variable "load_balancer_name" {
  type        = string
  description = "Name of the load balancer"
}

variable "load_balancer_internal" {
  type        = bool
  description = "Whether the load balancer is internal"
}

variable "load_balancer_type" {
  type        = string
  description = "Type of the load balancer"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs for the load balancer"
  default     = null
}

variable "eips" {
  type        = list(string)
  description = "List of Elastic IP IDs for the load balancer"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the load balancer"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the provisioned infrastructure"
}

variable "security_group_ids" {
  description = "Security groups IDS."
  type        = list(string)
  default     = []
}

variable "listeners" {
  type = list(object({
    name            = string
    port            = string
    protocol        = string
    ssl_policy      = optional(string)
    certificate_arn = optional(string)
    default_action = optional(object({
      type             = string
      target_group_arn = optional(string) ##for NLB
      fixed_response = optional(object({
        content_type = string
        status_code  = string
        message_body = optional(string)
      }))
      redirect = optional(object({
        port        = string
        protocol    = string
        status_code = string
      }))
      forward = optional(object({
        target_groups = list(object({
          arn    = string
          weight = optional(number)
        }))
        stickiness = optional(object({
          enabled  = bool
          duration = optional(number)
        }))
      }))
    }))
    rules = optional(list(object({
      actions = list(object({
        type = string
        fixed_response = optional(object({
          content_type = string
          status_code  = string
          message_body = optional(string)
        }))
        redirect = optional(object({
          port        = string
          protocol    = string
          status_code = string
        }))
        forward = optional(object({
          target_groups = list(object({
            arn    = string
            weight = optional(number)
          }))
          stickiness = optional(object({
            enabled  = bool
            duration = optional(number)
          }))
        }))
      }))
      conditions = list(object({
        host_headers = optional(list(string))
        http_headers = optional(list(object({
          header_name = string
          values      = list(string)
        })))
        path_patterns = optional(list(string))
      }))
    })))
  }))
}

variable "ingress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
    prefix_list_ids = optional(list(string), [])
  }))
  default = []
}