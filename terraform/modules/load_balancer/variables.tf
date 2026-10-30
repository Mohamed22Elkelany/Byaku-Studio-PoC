variable "load_balancer_name" {
  description = "The name of the load balancer."
  type        = string
}

variable "load_balancer_internal" {
  description = "Indicates whether the load balancer is internal or internet-facing."
  type        = bool
}

variable "load_balancer_type" {
  description = "The type of the load balancer (e.g., application, network, gateway)."
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs to associate with the load balancer."
  type        = list(string)
  default     = null
}

variable "eips" {
  description = "A list of Elastic IP IDs to assign to the load balancer (for NLB in static IP mode)."
  type        = list(string)
  default     = null
}

variable "vpc_id" {
  description = "The ID of the VPC where the load balancer will be deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the provisioned infrastructure."
  type        = map(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the load balancer."
  type        = list(string)
  default     = []
}

variable "drop_invalid_header_fields" {
  description = <<-EOT
    Specifies whether invalid HTTP headers should be dropped before forwarding requests
    to the target containers. Accepts true or false.
  EOT
  type        = bool
  default     = false
}

variable "listeners" {
  description = <<-EOT
    Configuration for the load balancer listeners, including protocols, ports,
    SSL settings, default actions, and optional rules for advanced routing.
  EOT
  type = list(object({
    name            = string
    port            = string
    protocol        = string
    ssl_policy      = optional(string)
    certificate_arn = optional(string)
    default_action = optional(object({
      type             = string
      target_group_arn = optional(string) # For NLB
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
  description = <<-EOT
    A list of ingress rules to control inbound traffic to the load balancer.
    Each rule includes ports, protocols, and source information.
  EOT
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
