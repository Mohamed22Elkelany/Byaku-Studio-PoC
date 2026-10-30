# General
aws_region       = "eu-west-1"
secondary_region = "us-east-1"
environment      = "poc"
environment_name = "poc"
project          = "byaku"

# TODO: add the team distribution list(s); each address must confirm the SNS subscription email.
alert_email_endpoints = []

#####################################################
##                   VPC Variables                 ##
#####################################################
vpc_cidr = "10.0.0.0/16"
public_subnets = [
  { cidr = "10.0.0.0/24", availability_zone = "eu-west-1a", map_public_ip_on_launch = false },
  { cidr = "10.0.1.0/24", availability_zone = "eu-west-1b", map_public_ip_on_launch = false }
]
private_subnets = [
  { cidr = "10.0.16.0/20", availability_zone = "eu-west-1a", tier = "app" },
  { cidr = "10.0.32.0/20", availability_zone = "eu-west-1b", tier = "app" },
  { cidr = "10.0.48.0/24", availability_zone = "eu-west-1a", tier = "data" },
  { cidr = "10.0.49.0/24", availability_zone = "eu-west-1b", tier = "data" },
  # Third data AZ so a later move to RDS Multi-AZ has room.
  { cidr = "10.0.50.0/24", availability_zone = "eu-west-1c", tier = "data" }
]

# PoC: one shared zonal NAT gateway and no interface endpoints (ECR, logs go through NAT).
nat_gateway_mode        = "zonal"
single_nat_gateway      = true
vpc_interface_endpoints = []

#####################################################
##                  ALB Variables                  ##
#####################################################
alb_config = {
  load_balancer_internal     = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
}

alb_security_group_config = {
  description = "Security group for the Byaku application load balancer"
  ingress_rules = [
    {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# DNS-validated wildcard certificate; the validation CNAME (output
# acm_certificate_validation_records) goes in the byaku-studio.com Cloudflare zone.
acm_certificate_domain = "*.byaku-studio.com"

# Stage 2: set to true once acm_certificate_status is ISSUED.
https_enabled = false

#####################################################
##                  WAF Variables                  ##
#####################################################
waf = {
  scope                        = "REGIONAL"
  name                         = "waf"
  allow_default_action         = true
  create_alb_association       = true
  cloudwatch_metrics_enabled   = true
  sampled_requests_enabled     = true
  create_logging_configuration = true
  log_retention_in_days        = 30
}

#####################################################
##                  ECR Variables                  ##
#####################################################
# Repositories are created as <project>-<environment_name>/<service>, e.g. byaku-poc/backend.
# Immutable tags, scan on push, AES256.
ecr = {
  repository_names     = ["backend", "web", "admin-web", "integrations", "ai", "db-migrate", "admin-db-migrate"]
  image_tag_mutability = "IMMUTABLE"
  image_scanning       = true
  keep_images          = 20
}

#####################################################
##                  ECS Variables                  ##
#####################################################
ecs_cluster = {
  capacity_providers         = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider  = "FARGATE_SPOT"
  container_insights         = "disabled"
  create_service_linked_role = true
}

#####################################################
##             Cloud Trail Variables               ##
#####################################################
cloudtrail_config = {
  s3_bucket = {
    versioning_enabled      = true
    bucket_key_enabled      = true
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    force_destroy           = true
    sse_algorithm           = "AES256"
    privileged_services     = []
  }
  log_group = {
    log_group_class   = "STANDARD"
    retention_in_days = 90
  }
  trail = {
    is_multi_region_trail = true
    enable_logging        = true
  }
  s3_lifecycle_rules = [
    {
      id              = "ExpireOldVersions"
      status          = "Enabled"
      noncurrent_days = 30
    }
  ]
}

#####################################################
##             Security Hub Variables              ##
#####################################################
# Enabling Security Hub subscribes the account to the AWS default standards.
security_hub = {
  enable_aggregation = false
}

guardduty_enabled = true

#####################################################
##            Budgets Alarms Variables             ##
#####################################################
# Notifications always go to the alerting SNS topic (see budgets.tf).
budgets = {
  overall = {
    name         = "overall-monthly"
    limit_amount = 400
    notifications = {
      actual     = { comparison_operator = "GREATER_THAN", threshold = 80, threshold_type = "PERCENTAGE", notification_type = "ACTUAL" }
      forecasted = { comparison_operator = "GREATER_THAN", threshold = 100, threshold_type = "PERCENTAGE", notification_type = "FORECASTED" }
    }
  }

  networking = {
    name         = "networking-monthly"
    limit_amount = 120
    cost_filters = [{ name = "Service", values = ["EC2 - Other", "Amazon Virtual Private Cloud", "Amazon Elastic Load Balancing"] }]
    notifications = {
      actual     = { comparison_operator = "GREATER_THAN", threshold = 85, threshold_type = "PERCENTAGE", notification_type = "ACTUAL" }
      forecasted = { comparison_operator = "GREATER_THAN", threshold = 100, threshold_type = "PERCENTAGE", notification_type = "FORECASTED" }
    }
  }

  rds = {
    name         = "rds-monthly"
    limit_amount = 100
    cost_filters = [{ name = "Service", values = ["Amazon Relational Database Service"] }]
    notifications = {
      actual     = { comparison_operator = "GREATER_THAN", threshold = 85, threshold_type = "PERCENTAGE", notification_type = "ACTUAL" }
      forecasted = { comparison_operator = "GREATER_THAN", threshold = 100, threshold_type = "PERCENTAGE", notification_type = "FORECASTED" }
    }
  }

  monitoring_security = {
    name         = "monitoring-security-monthly"
    limit_amount = 100
    cost_filters = [{ name = "Service", values = ["AmazonCloudWatch", "AWS CloudTrail", "AWS Config", "AWS Security Hub", "Amazon GuardDuty", "AWS WAF"] }]
    notifications = {
      actual     = { comparison_operator = "GREATER_THAN", threshold = 85, threshold_type = "PERCENTAGE", notification_type = "ACTUAL" }
      forecasted = { comparison_operator = "GREATER_THAN", threshold = 100, threshold_type = "PERCENTAGE", notification_type = "FORECASTED" }
    }
  }
}

# Additional alarms beyond the baseline ALB/WAF alarms in cloudwatch.tf.
cloudwatch_alarms = []

#####################################################
##        Application (ECS) Variables              ##
#####################################################
app_hostnames = {
  app   = "app.byaku-studio.com"
  admin = "admin.byaku-studio.com"
  api   = "api.byaku-studio.com"
}

# Admin web is reachable only from these source ranges (VPC only when empty).
admin_allowed_cidrs = []

# PoC sizing (ARM64, default 20 GiB ephemeral storage).
ecs_task_sizes = {
  web              = { cpu = 512, memory = 1024 }
  admin-web        = { cpu = 512, memory = 1024 }
  backend          = { cpu = 1024, memory = 2048 }
  integrations     = { cpu = 256, memory = 1024 }
  ai               = { cpu = 256, memory = 1024 }
  db-migrate       = { cpu = 1024, memory = 2048 }
  admin-db-migrate = { cpu = 1024, memory = 2048 }
}

# Services stay at 0 tasks until images are published; the CD pipeline owns rollouts.
ecs_desired_count = {}

live_llm                  = "false"
app_log_retention_in_days = 30

#####################################################
##                      RDS                        ##
#####################################################
# Core ("byaku") and admin ("byaku_admin") PostgreSQL stores, created empty
# (no snapshot restore). Master passwords are RDS-managed in Secrets Manager.
# PoC sizing: Single-AZ db.t4g.small, 20 GiB gp3 (baseline 3000 IOPS / 125 MiB/s)
# growing up to 100 GiB.
db_instances = {
  core = {
    db_name                         = "byaku"
    db_username                     = "byaku_app"
    engine_version                  = "16.13"
    instance_class                  = "db.t4g.small"
    allocated_storage               = 20
    max_allocated_storage           = 100
    apply_immediately               = true
    multi_az                        = false
    deletion_protection             = true
    backup_retention_period         = 7
    backup_window                   = "01:00-02:00"
    maintenance_window              = "sun:02:30-sun:03:30"
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
    manage_master_user_password     = true
    allowed_services                = ["backend", "integrations", "migration"]
  }
  admin = {
    db_name                         = "byaku_admin"
    db_username                     = "byaku_admin_app"
    engine_version                  = "16.13"
    instance_class                  = "db.t4g.small"
    allocated_storage               = 20
    max_allocated_storage           = 100
    apply_immediately               = true
    multi_az                        = false
    deletion_protection             = true
    backup_retention_period         = 7
    backup_window                   = "01:00-02:00"
    maintenance_window              = "sun:02:30-sun:03:30"
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
    manage_master_user_password     = true
    allowed_services                = ["backend", "migration"]
  }
}
