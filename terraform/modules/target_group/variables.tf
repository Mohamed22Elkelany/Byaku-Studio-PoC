variable "target_group_name" {
  description = "The name of the target group"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the target group will be created"
  type        = string
}

variable "protocol" {
  description = "The protocol for connections from clients to the load balancer"
  type        = string
  default     = "HTTP"
}

variable "health_check_protocol" {
  description = "The protocol for health check"
  type        = string
  default     = "HTTP"
}
variable "port" {
  description = "The port on which the target group listens"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "The destination for the health check request"
  type        = string
  default     = "/"
}

variable "target_type" {
  description = "The type of target that you must specify when registering targets with this target group"
  type        = string
  default     = "instance"
}

variable "interval" {
  description = "The interval at which the health check operates."
  type        = number
  default     = 30 # You can set a default value or leave it out for mandatory input
}

variable "timeout" {
  description = "The amount of time to wait before considering the health check a failure."
  type        = number
  default     = 5 # You can set a default value or leave it out for mandatory input
}

variable "healthy_threshold" {
  description = "The number of consecutive successful health checks required before considering the server healthy."
  type        = number
  default     = 3 # You can set a default value or leave it out for mandatory input
}

variable "unhealthy_threshold" {
  description = "The number of consecutive failed health checks required before considering the server unhealthy."
  type        = number
  default     = 2 # You can set a default value or leave it out for mandatory input
}

variable "matcher" {
  description = "The condition or pattern used to evaluate the health check."
  type        = string        # Adjust the type if necessary, e.g., number or list(string)
  default     = "200,301,302" # Default value as an example; adjust based on actual expected use
}

variable "attach_target" {
  description = "Indicates whether the resource should be attached to an Elastic Load Balancer."
  type        = bool
  default     = false # Set the default based on your typical use case, true or false
}

variable "attachment_target_id" {
  description = "The ID of the target to which the resource should be attached."
  type        = string # Assuming the ID is a string
  default     = null
}

variable "attachment_target_port" {
  description = "The port number on the target to which the resource should connect."
  type        = number # Ports are typically represented as numbers
  default     = null
}

variable "stickiness_cookie_name" {
  description = "Name of the application based cookie. Must not start with AWSALB, AWSALBAPP, or AWSALBTG as these prefixes are reserved. Only required when type is 'app_cookie'."
  type        = string
  default     = null # Set to null as it's optional and only needed conditionally
}

variable "stickiness_enabled" {
  description = "Boolean to enable or disable stickiness. Default is true."
  type        = bool
  default     = true # Default is set to true as mentioned
}

variable "stickiness_type" {
  description = "The type of stickiness for the load balancer (e.g., lb_cookie, application_cookie)"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "The cookie duration in seconds for the stickiness policy"
  type        = number
  default     = 86400
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}