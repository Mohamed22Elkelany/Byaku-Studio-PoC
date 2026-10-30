variable "ami_id" {
  description = "The Amazon Machine Image (AMI) ID to use for the instance."
  type        = string
}

variable "instance_type" {
  description = "The type of instance to be provisioned (e.g., t2.micro, m5.large)."
  type        = string
}

variable "keypair_name" {
  description = "The name of the SSH key pair to associate with the instance."
  type        = string
}

variable "instance_name" {
  description = "The name to assign to the EC2 instance."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the instance will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet within the VPC to deploy the instance."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
  default     = []
}

variable "ingress_rules" {
  description = <<-EOT
    A list of ingress rules for configuring network access to the instance.
    Each rule includes ports, protocols, and sources.
  EOT
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
  description = <<-EOT
    A list of egress rules for configuring outbound network access from the instance.
    Each rule includes ports, protocols, and destinations.
  EOT
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

variable "iam_permissions" {
  description = "A list of IAM permissions to assign to the instance role."
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance."
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = <<-EOT
    Configuration for the root block device of the instance.
    Includes size, type, encryption, and deletion settings.
  EOT
  type = object({
    size                  = number
    type                  = string
    encrypted             = bool
    delete_on_termination = bool
  })
  default = {
    size                  = 100
    type                  = "gp3"
    encrypted             = true
    delete_on_termination = true
  }
}

variable "tags" {
  description = "A map of tags to assign to the provisioned infrastructure."
  type        = map(string)
  default     = {}
}

variable "disable_api_stop" {
  description = "disable_api_stop"
  type        = bool
  default     = true
}
variable "disable_api_termination" {
  description = "disable_api_termination"
  type        = bool
  default     = true
}