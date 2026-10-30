###########################################
##            General Variables          ##
###########################################
variable "aws_profile" {
  description = "Optional AWS shared credentials profile for local Terraform runs. CI uses OIDC environment credentials."
  type        = string
  default     = null
}

variable "aws_region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "eu-west-1"
}

variable "secondary_region" {
  description = "The secondary AWS region for failover or disaster recovery."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The deployment environment (e.g., poc, staging or prod)."
  type        = string

  validation {
    condition     = contains(["poc", "staging", "prod"], var.environment)
    error_message = "environment must be one of \"poc\", \"staging\" or \"prod\"."
  }
}

variable "environment_name" {
  description = <<-EOT
    Release environment name used by the application CI/CD (GitHub environment and
    resource prefix "<project>-<environment_name>"), e.g. "poc", "staging" or "production".
  EOT
  type        = string

  validation {
    condition     = contains(["poc", "staging", "production"], var.environment_name)
    error_message = "environment_name must be one of \"poc\", \"staging\" or \"production\"."
  }
}

variable "project" {
  description = "The name of the project, used as a prefix for the resources."
  type        = string
  default     = "byaku"
}

###########################################
##             Tags Variables            ##
###########################################
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the provisioned infrastructure."
  default     = {}
}

###########################################
##            VPC Variables              ##
###########################################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnets, each defined by its CIDR block, availability zone, and public IP mapping configuration."
  type = list(object({
    cidr                    = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
  default = []
}

variable "private_subnets" {
  description = <<-EOT
    A list of private subnets, each defined by its CIDR block, availability zone and tier.
    Use exactly one "app" subnet per AZ (ECS tasks, VPC interface endpoints) and
    "data" subnets for the databases.
  EOT
  type = list(object({
    cidr              = string
    availability_zone = string
    tier              = optional(string, "app")
  }))
  default = []
}

variable "nat_gateway_mode" {
  description = "\"zonal\" NAT gateways (see single_nat_gateway) or one \"regional\" multi-AZ NAT gateway."
  type        = string
  default     = "zonal"
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ (cheaper, but not AZ-resilient)."
  type        = bool
  default     = false
}

variable "vpc_interface_endpoints" {
  description = "AWS service names (without the com.amazonaws.<region>. prefix) to expose through VPC interface endpoints, e.g. [\"ecr.api\", \"ecr.dkr\", \"logs\"]."
  type        = list(string)
  default     = []
}

###########################################
##         LoadBalancer Variables        ##
###########################################
variable "alb_config" {
  description = "Configuration for the ALB excluding the load balancer name"
  type = object({
    load_balancer_internal     = optional(bool, false)
    load_balancer_type         = optional(string, "application")
    drop_invalid_header_fields = optional(bool, true)
  })
}

variable "alb_security_group_config" {
  description = "Configuration for the ALB's security group"
  type = object({
    description = optional(string, "Security Group for the ALB to allow HTTP and HTTPS traffic.")
    ingress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  })
}

variable "acm_certificate_domain" {
  description = "Environment wildcard certificate (DNS-validated) for the public ALB, e.g. *.byaku-studio.com."
  type        = string
}

variable "https_enabled" {
  description = <<-EOT
    Stage 2 switch for the public ALB: adds the HTTPS listener with the ACM
    certificate and redirects HTTP to HTTPS. Set it only once the certificate is
    ISSUED (its validation CNAME exists); until then the ALB serves HTTP.
  EOT
  type        = bool
  default     = false
}

###########################################
##            WAF Variables              ##
###########################################
variable "waf" {
  description = "WAF vars"
  type = object({
    scope                        = optional(string, "REGIONAL")
    name                         = string
    allow_default_action         = bool
    create_alb_association       = bool
    cloudwatch_metrics_enabled   = bool
    sampled_requests_enabled     = bool
    create_logging_configuration = bool
    log_retention_in_days        = optional(number, 90)
  })
}

###########################################
##            ECR Variables              ##
###########################################
variable "ecr" {
  description = "ECR repositories for the application images. Repositories are named <project>-<environment_name>/<service>."
  type = object({
    repository_names = optional(list(string), [
      "backend", "web", "admin-web", "integrations", "ai", "db-migrate", "admin-db-migrate"
    ])
    image_tag_mutability = optional(string, "IMMUTABLE")
    image_scanning       = optional(bool, true)
    keep_images          = optional(number, 20)
  })
  default = {}
}

###########################################
##             ECS Variables             ##
###########################################
variable "ecs_cluster" {
  description = "ECS cluster configuration."
  type = object({
    capacity_providers        = optional(list(string), ["FARGATE", "FARGATE_SPOT"])
    default_capacity_provider = optional(string, "FARGATE")
    container_insights        = optional(string, "enabled")
    # Create the AWSServiceRoleForECS service-linked role. Set to false in
    # accounts where it already exists (it is account-wide and can exist only once).
    create_service_linked_role = optional(bool, true)
  })
  default = {}
}

###########################################
##         Cloud trail Variables         ##
###########################################
variable "cloudtrail_config" {
  description = "Configuration for CloudTrail, S3 Bucket, and Log Group"
  type = object({
    s3_bucket = object({
      versioning_enabled      = bool
      bucket_key_enabled      = bool
      block_public_acls       = bool
      block_public_policy     = bool
      ignore_public_acls      = bool
      restrict_public_buckets = bool
      force_destroy           = bool
      sse_algorithm           = string
      privileged_services = list(object({
        principal_type        = string
        principal_identifiers = string
        actions               = list(string)
        resources             = list(string)
        conditions = list(object({
          test     = string
          variable = string
          values   = list(string)
        }))
      }))
    })
    log_group = object({
      log_group_class   = string
      retention_in_days = optional(number, 90)
    })
    trail = object({
      is_multi_region_trail = bool
      enable_logging        = bool
    })
    s3_lifecycle_rules = optional(list(object({
      id              = string
      status          = string
      noncurrent_days = number
    })), [])
  })
}

###########################################
##        Security Hub Variables         ##
###########################################
variable "security_hub" {
  description = <<-EOT
    Configuration for AWS Security Hub.
    Includes options to enable aggregation and specify standards ARNs.
  EOT
  type = object({
    enable_aggregation = bool
    standards_arns     = optional(list(string))
  })
}

###########################################
##           Guard Duty Variables        ##
###########################################
variable "guardduty_enabled" {
  description = "Enable or disable GuardDuty for the account"
  type        = bool
  default     = true
}

###########################################
##     Alerting / CloudWatch Variables   ##
###########################################
variable "alert_email_endpoints" {
  description = "List of email addresses subscribed to the alerting SNS topic (CloudWatch alarms and budgets)."
  type        = list(string)
  default     = []
}

variable "cloudwatch_alarms" {
  description = "Additional CloudWatch alarms on top of the baseline alarms in cloudwatch.tf. sns_topic_arn defaults to the alerting topic."
  type = list(object({
    name                = string
    metric_name         = string
    namespace           = string
    threshold           = number
    comparison_operator = string
    evaluation_periods  = number
    statistic           = string
    period              = optional(number, 300)
    dimensions          = map(string)
    description         = string
    sns_topic_arn       = optional(string)
  }))
  default = []
}

###########################################
##        Budgets Variables              ##
###########################################
variable "budgets" {
  description = "A map of budget configurations. Every notification is also sent to the alerting SNS topic."
  type = map(object({
    name              = string
    type              = optional(string, "COST")
    limit_amount      = number
    limit_unit        = optional(string, "USD")
    time_unit         = optional(string, "MONTHLY")
    time_period_start = optional(string)
    cost_filters = optional(list(object({
      name   = string
      values = list(string)
    })), [])
    notifications = map(object({
      comparison_operator        = string
      threshold                  = number
      threshold_type             = string
      notification_type          = string
      subscriber_sns_topic_arns  = optional(list(string), [])
      subscriber_email_addresses = optional(list(string))
    }))
    cost_types = optional(object({
      include_credit             = optional(bool, true)
      include_discount           = optional(bool, false)
      include_other_subscription = optional(bool, true)
      include_recurring          = optional(bool, true)
      include_refund             = optional(bool, true)
      include_subscription       = optional(bool, true)
      include_support            = optional(bool, true)
      include_tax                = optional(bool, true)
      include_upfront            = optional(bool, true)
      use_blended                = optional(bool, true)
      use_amortized              = optional(bool, false)
    }), {})
  }))
  default = {}
}

###########################################
##   Application (ECS) Variables         ##
###########################################
variable "app_hostnames" {
  description = "Public host names routed by the ALB to the customer web, admin web and backend API."
  type = object({
    app   = string
    admin = string
    api   = string
  })
}

variable "admin_allowed_cidrs" {
  description = <<-EOT
    Source CIDRs allowed to reach the admin web through the ALB. The admin surface
    must stay private; when empty only the VPC CIDR is allowed.
  EOT
  type        = list(string)
  default     = []
}

variable "ecs_task_sizes" {
  description = <<-EOT
    Fargate sizing per task family (web, admin-web, backend, integrations, ai,
    db-migrate, admin-db-migrate, private-smoke): cpu units, memory MiB and optional
    ephemeral storage GiB (21-200; Fargate default 20). Families not listed keep the
    default sizing in ecs_tasks.tf.
  EOT
  type = map(object({
    cpu               = number
    memory            = number
    ephemeral_storage = optional(number)
  }))
  default = {}
}

variable "ecs_desired_count" {
  description = <<-EOT
    Desired task count per ECS service (web, admin-web, backend, ai, integrations).
    Defaults to 0 until images are published; afterwards the CD pipeline owns
    rollouts and Terraform ignores desired_count drift.
  EOT
  type        = map(number)
  default     = {}
}

variable "live_llm" {
  description = "LIVE_LLM flag for the backend (\"false\" keeps live models disabled)."
  type        = string
  default     = "false"
}

# Out of scope for the PoC; uncomment with bedrock.tf.
# variable "bedrock_models" {
#   description = <<-EOT
#     Global cross-Region inference profiles for the backend (bedrock.tf):
#     pipeline (Claude Opus) drives criteria/extract/judge/remediate/narrate,
#     assistant (Claude Sonnet) drives the customer chatbot and admin copilot.
#     Only these profiles are allowed by the backend task role.
#   EOT
#   type = object({
#     pipeline  = string
#     assistant = string
#   })
#   default = {
#     pipeline  = "global.anthropic.claude-opus-4-6-v1"
#     assistant = "global.anthropic.claude-sonnet-4-6"
#   }
#
#   validation {
#     condition     = alltrue([for m in values(var.bedrock_models) : startswith(m, "global.anthropic.")])
#     error_message = "bedrock_models must be global.anthropic.* inference profile IDs."
#   }
# }

variable "app_log_retention_in_days" {
  description = "Retention for the application and migration log groups."
  type        = number
  default     = 30
}


###########################################################################
# OUT OF SCOPE (commented out): variables for the phase 2 services
# (ElastiCache, CloudFront, dashboards).
###########################################################################

###########################################
##          RDS Configuration            ##
###########################################
###########################################
##           RDS Variables               ##
###########################################
variable "db_instances" {
  description = <<-EOT
    RDS PostgreSQL instances keyed by store (core, admin), created empty.
    allowed_services lists the ECS security groups (keys of aws_security_group.app)
    allowed to connect on 5432.
  EOT
  type = map(object({
    db_identifier                   = optional(string)
    db_name                         = optional(string)
    db_username                     = string
    engine                          = optional(string, "postgres")
    engine_version                  = string
    engine_lifecycle_support        = optional(string)
    instance_class                  = string
    allocated_storage               = number
    max_allocated_storage           = number
    multi_az                        = bool
    storage_type                    = optional(string, "gp3")
    storage_encrypted               = optional(bool, true)
    storage_throughput              = optional(number)
    provisioned_iops                = optional(number)
    deletion_protection             = bool
    skip_final_snapshot             = optional(bool, false)
    apply_immediately               = optional(bool, false)
    backup_retention_period         = number
    backup_window                   = string
    maintenance_window              = string
    copy_tags_to_snapshot           = optional(bool, true)
    delete_automated_backups        = optional(bool, false)
    enabled_cloudwatch_logs_exports = optional(list(string), [])
    manage_master_user_password     = optional(bool, true)
    performance_insights_enabled    = optional(bool, false)
    monitoring_interval             = optional(number, 0)
    allowed_services                = list(string)
  }))
  default = {}
}

# variable "db_instance_passwords" {
#   type        = map(string)
#   description = "Map of RDS database passwords for each db_instance"
#   sensitive   = true
#   default     = {}
# }

# variable "elastic_cache" {
#   type = object({
#     engine                                 = string
#     engine_version                         = string
#     node_type                              = string
#     parameter_group_family                 = string
#     transit_encryption_enabled             = optional(bool, true)
#     at_rest_encryption_enabled             = optional(bool, true)
#     create_replication_group               = optional(bool, false)
#     num_cache_nodes                        = optional(number, 1)
#     redis_port                             = optional(number, 6379)
#     multi_az_enabled                       = optional(bool, false)
#     apply_modification_updates_immediately = optional(bool, false)
#     ingress_rules = optional(list(object({
#       from_port       = number
#       to_port         = number
#       protocol        = string
#       description     = string
#       cidr_blocks     = optional(list(string), [])
#       security_groups = optional(list(string), [])
#     })), [])
#     egress_rules = optional(list(object({
#       from_port       = number
#       to_port         = number
#       protocol        = string
#       description     = string
#       cidr_blocks     = optional(list(string), ["0.0.0.0/0"])
#       security_groups = optional(list(string), [])
#       })), [
#       {
#         description = "Allow all outbound traffic"
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#       }
#     ])
#   })
#   description = "the Elastic Cache Configurations"
# }

# variable "cloudfront" {
#   description = "CloudFront distribution configuration for the media origin."
#   type = object({
#     enabled             = bool
#     aliases             = list(string)
#     comment             = string
#     is_ipv6_enabled     = bool
#     price_class         = string
#     restriction_type    = string
#     locations           = list(string)
#     viewer_protocol     = string
#     minimum_tls_version = string
#   })
# }

# variable "CloudWatch_dashboard" {
#   description = "CloudWatch dashboard vars"
#   type = object({
#     cloudwatch_agent_namespace = string
#   })
# }
