variable "listener_name" {
  description = "Name of the listener"
  type        = string
}

variable "load_balancer_arn" {
  description = "The ARN of the ELB"
  type        = string
}

variable "port" {
  description = "The port on which the load balancer is listening"
  type        = string
}

variable "protocol" {
  description = "Protocol for connections from clients to the load balancer"
  type        = string
}

variable "ssl_policy" {
  description = "Name of the SSL Policy for the listener"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN of the default SSL server certificate"
  type        = string
  default     = null
}

variable "default_action" {
  description = "Configuration block for default actions"
  type = object({
    type             = string
    target_group_arn = optional(string) ## For NLB
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
  })
  default = {
    type             = "fixed-response"
    target_group_arn = "null"
    fixed_response = {
      content_type = "text/plain"
      status_code  = "501"
      message_body = "Not Implemented"
    }
  }
}

variable "rules" {
  description = "Load balancer rules"
  type = list(object({
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
  }))
  default = []
}

variable "tags" {
  description = "Tags to be added to the provisioned infrastructure"
  type        = map(string)
}