variable "name" {
  description = "Name of the task family"
  type        = string
}

variable "cpu" {
  description = "CPU value for the task"
  type        = string
}

variable "memory" {
  description = "Memory value for the task"
  type        = string
}

variable "network_mode" {
  description = "Network mode for the task"
  type        = string
}

variable "requires_compatibilities" {
  description = "The launch type for the task (FARGATE, EC2)"
  type        = list(string)
}

# variable "execution_role_arn" {
#   description = "ARN of the task execution role"
#   type        = string
# }

# variable "task_role_arn" {
#   description = "ARN of the task role"
#   type        = string
# }

# variable "container_definitions" {
#   description = "JSON-encoded container definitions"
#   type        = string
# }

variable "log_group_create" {
  description = "Whether to create Log Group for the task"
  type        = bool
  default     = true
}

variable "log_group_region" {
  type        = string
  description = "The AWS region"
  default     = "me-central-1"
}

variable "cpu_architecture" {
  description = "value"
  type        = string
  default     = "X86_64"
}

variable "operating_system_family" {
  description = "(optional) describe your variable"
  type        = string
  default     = "LINUX"
}

variable "ecs_execution_role_name" {
  type        = string
  description = "Name of the ECS excution role"
}

variable "ecs_task_role_name" {
  type        = string
  description = "Name of the ECS execution role"
}

variable "enable_efs" {
  description = "Whether to enable EFS volume for the task"
  type        = bool
  default     = true
}

variable "efs_file_system_id" {
  description = "The ID of the EFS file system"
  type        = string
}

variable "efs_root_directory" {
  description = "The root directory path on the EFS file system"
  type        = string
  default     = "/media"
}

variable "tags" {
  description = "A map of tags to apply to the cluster"
  type        = map(string)
  default     = {}
}

variable "secret_arns" {
  type        = list(string)
  description = "List of Secrets Manager ARNs to inject as ECS environment variables"
  default     = []
}

variable "secret_keys" {
  type        = list(string)
  description = "Secret JSON keys to inject as ECS environment variables without reading secret values into Terraform state."
  default     = []
}

variable "environment_variables" {
  type        = map(string)
  description = "Non-sensitive environment variables for the container."
  default     = {}
}


variable "exclude_secret_keys" {
  description = "List of secret keys to exclude from being loaded as environment variables"
  type        = list(string)
  default     = []
}

variable "repo_name" {
  description = "ECR repository URL for the container image"
  type        = string
}

variable "container_image_tag" {
  description = "Docker image tag for the container"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = null
}

variable "host_port" {
  description = "Port on the host to map to the container port"
  type        = number
  default     = null
}

variable "container_command" {
  description = "Optional command override for the container. When null, the image ENTRYPOINT/CMD is used."
  type        = list(string)
  default     = null
}

variable "health_check" {
  description = "Optional ECS container health check."
  type = object({
    command      = list(string)
    interval     = number
    timeout      = number
    retries      = number
    start_period = number
  })
  default = null
}

variable "stop_timeout" {
  description = "Seconds ECS waits before forcefully stopping the container."
  type        = number
  default     = 30
}
