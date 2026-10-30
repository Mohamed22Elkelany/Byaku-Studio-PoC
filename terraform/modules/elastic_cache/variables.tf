variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "cluster_id" {
  description = "The ID of the ElastiCache cluster."
  type        = string
}

variable "engine" {
  description = "The name of the cache engine (e.g., redis or memcached)."
  type        = string
}

variable "engine_version" {
  description = "The version number of the cache engine to be used."
  type        = string
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes."
  type        = string
}

variable "num_cache_nodes" {
  description = "The number of cache nodes for the cluster."
  type        = number
  default     = 1
}

variable "create_replication_group" {
  description = "Whether to manage Redis as a replication group. Enabling this for an existing cluster requires a deliberate migration/replacement."
  type        = bool
  default     = false
}

variable "redis_port" {
  description = "The port number on which each member of the replication group accepts connections."
  type        = number
  default     = 6379
}

variable "ealstic_cache_subnet_ids" {
  description = "List of VPC Subnet IDs for the Elasticache subnet group"
  type        = list(string)
}

variable "apply_modification_updates_immediately" {
  description = "Whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "subnet_group_description" {
  description = "The discription of the Elastic cache subnet group"
  type        = string
  default     = "ElastiCache subnet group"
}

variable "parameter_group_description" {
  description = "Description of the Paramater Group"
  type        = string
  default     = "ElastiCache parameter group"
}

variable "parameter_group_family" {
  description = "The Family type of the paramater group"
  type        = string
}

variable "multi_az_enabled" {
  description = "Single or Multi Avalibility Zone"
  type        = bool
}

variable "parameters" {
  description = "List of ElastiCache parameters to apply"
  type        = list(map(string))
  default     = []
}

variable "ingress_rules" {
  description = "Ingress Rules for the Elastic Cache"
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
  description = "Egress Rules for the Elastic Cache"
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

variable "enabled_log_types" {
  description = "List of log types to enable (e.g., ['slow-log', 'engine-log']). This is only applicable for Redis."
  type        = list(string)
  default     = ["slow-log", "engine-log"]
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs in CloudWatch."
  type        = number
  default     = 30
}

variable "auth_token" {
  description = "The password used to access a password protected server. Can be specified only if transit_encryption_enabled = true"
  type        = string
  default     = null
  sensitive   = true
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit"
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "Whether to enable encryption at rest"
  type        = bool
  default     = true
}

variable "tags" {
  description = <<-EOT
    Tags to be added to the provisioned infrastructure.
  EOT
  type        = map(string)
  default     = {}
}
