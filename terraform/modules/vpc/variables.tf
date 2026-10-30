variable "vpc_cidr" {
  description = "The CIDR block to assign to the VPC."
  type        = string
}

variable "vpc_name" {
  description = "The name to assign to the VPC."
  type        = string
}

variable "enable_dns_support" {
  description = "Indicates whether DNS support is enabled for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Indicates whether DNS hostnames are enabled for the VPC."
  type        = bool
  default     = false
}

variable "public_subnets" {
  description = "A list of public subnets with CIDR blocks, availability zones, and mapping options for public IPs."
  type = list(object({
    cidr                    = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
  default = []
}

variable "private_subnets" {
  description = <<-EOT
    A list of private subnets with CIDR blocks and availability zones.
    `tier` groups subnets by purpose (e.g. app, data) and is exposed through the
    `private_subnet_ids_by_tier` output.
  EOT
  type = list(object({
    cidr              = string
    availability_zone = string
    tier              = optional(string, "app")
  }))
  default = []
}

variable "nat_gateway_mode" {
  description = "\"zonal\" (one NAT gateway per public-subnet AZ, or one with single_nat_gateway) or \"regional\" (one multi-AZ regional NAT gateway)."
  type        = string
  default     = "zonal"

  validation {
    condition     = contains(["zonal", "regional"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be \"zonal\" or \"regional\"."
  }
}

variable "single_nat_gateway" {
  description = "Create a single NAT gateway shared by all AZs instead of one NAT gateway per AZ."
  type        = bool
  default     = false
}

variable "vpc_flow_logs_retention_in_days" {
  description = "The number of days to retain VPC flow log events in the specified log group."
  type        = number
  default     = 90
}

variable "vpc_flow_logs_log_format" {
  description = <<-EOT
    The format of the VPC flow log records, specifying the fields to include.
    Default fields include version, VPC ID, subnet ID, instance ID, and more.
  EOT
  type        = string
  default     = "$${version} $${vpc-id} $${subnet-id} $${instance-id} $${interface-id} $${account-id} $${type} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${tcp-flags}"
}

variable "tags" {
  description = "Tags to assign to the VPC and its associated resources."
  type        = map(string)
  default     = {}
}

