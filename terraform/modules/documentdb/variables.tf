variable "cluster_identifier" {
  description = "The identifier for the DocumentDB cluster"
  type        = string
}

variable "parameter_group_name" {
  description = "The name of the DocumentDB parameter group"
  type        = string
  default     = null
}

variable "db_subnet_ids" {
  description = "List of subnet IDs for DocumentDB instances"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs for DocumentDB"
  type        = list(string)
}

variable "db_username" {
  description = "Master username for the DocumentDB cluster"
  type        = string
}

variable "db_password" {
  description = "Master password for the DocumentDB cluster"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "Number of days to retain backups for the DocumentDB cluster"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "parameters" {
  description = "Map of parameters for the DocumentDB parameter group"
  type        = map(string)
  default     = {}
}

variable "documentdb_config" {
  description = "Configuration for DocumentDB instances, including instance class and AZs"
  type = object({
    instance_class = string
    primary_az     = string
    replica_az     = string
  })
}

variable "parameter_group_family" {
  description = "The parameter group family for the DocumentDB cluster."
  type        = string
  default     = "docdb4.0" # Optional, set a default if needed
}

variable "instances" {
  description = "Map of instance configurations, including instance class and availability zone"
  type = map(object({
    availability_zone = string
  }))
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "07:00-09:00" # Default backup window
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}
