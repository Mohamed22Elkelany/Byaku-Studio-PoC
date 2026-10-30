variable "launch_template_name" {
  description = "The name of the launch template."
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the current vpc."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of the instance."
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile_name" {
  description = "The type of the instance."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key name to use for the instance."
  type        = string
  default     = ""
}

variable "image_id" {
  description = "Image ID to be used in the Launch Template"
  type        = string
}

variable "metadata_http_tokens" {
  description = "value"
  type        = string
  default     = "required"
}

variable "user_data" {
  description = "The user data to provide when launching the instance."
  type        = string
  default     = ""
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = false
}

variable "enable_instance_metadata_tags" {
  description = "Enable instance metadata tags."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the launch template."
  type        = map(string)
  default     = {}
}

variable "vpc_security_group_ids" {
  description = "Security groups IDS."
  type        = list(string)
  default     = []
}

variable "use_spot_instance" {
  description = "Whether to use spot instances."
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "The maximum price to pay for spot instances."
  type        = string
  default     = "0.05"
}

variable "spot_instance_type" {
  description = "The type of spot instance request."
  type        = string
  default     = "one-time"
}

variable "network_interface_id" {
  description = "The ID of the network interface to attach to the instance."
  type        = string
  default     = ""
}

variable "ami_name_prefix" {
  description = "The part before the date of the AMI name."
  type        = string
  default     = ""
}

variable "disable_api_termination" {
  description = "Whether to enables EC2 Instance Termination Protection."
  type        = bool
  default     = false
}

variable "disable_api_stop" {
  description = "Whether to enables EC2 Instance Stop Protection."
  type        = bool
  default     = false
}

variable "private_dns_name_options" {
  description = "Configuration options for private DNS names"
  type = object({
    enable_resource_name_dns_a_record    = optional(bool)
    enable_resource_name_dns_aaaa_record = optional(bool)
    hostname_type                        = optional(string)
  })
  default = null # Optional, specify null if no default value is desired, making the configuration optional
}

variable "block_device_mappings" {
  description = "List of block device mappings"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = string
    delete_on_termination = bool
    encrypted             = bool
    iops                  = number
    throughput            = number
  }))
  default = null
}

variable "ingress_rules" {
  description = "Ingress Rules of the EC2"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
  default = []
}

variable "egress_rules" {
  description = "Egress Rules of the EC2"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "iam_policy_arns" {
  description = "List of IAM policy ARNs to attach to the IAM role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ]
}