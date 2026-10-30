locals {
  module_name           = "tf-aws/elastic-cache"
  module_version        = file("${path.module}/RELEASE")
  module_maintainer     = "Alventara"
  use_replication_group = var.engine == "redis" && var.create_replication_group
  cluster_cache_nodes   = var.engine == "redis" ? 1 : var.num_cache_nodes
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_elasticache_parameter_group" "this" {
  description = var.parameter_group_description
  family      = var.parameter_group_family
  name        = "${var.cluster_id}-pg"

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(local.default_tags, var.tags, { Name = "${var.cluster_id}-pg" })

  lifecycle {
    create_before_destroy = true
  }
}

# Use replication group for Redis with authentication support
resource "aws_elasticache_replication_group" "this" {
  count = local.use_replication_group ? 1 : 0

  replication_group_id       = var.cluster_id
  description                = "Redis replication group for ${var.cluster_id}"
  engine                     = var.engine
  engine_version             = var.engine_version
  node_type                  = var.node_type
  num_cache_clusters         = var.num_cache_nodes
  port                       = var.redis_port
  parameter_group_name       = aws_elasticache_parameter_group.this.name
  security_group_ids         = [aws_security_group.this.id]
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  apply_immediately          = var.apply_modification_updates_immediately
  multi_az_enabled           = var.multi_az_enabled
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null
  transit_encryption_enabled = var.transit_encryption_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  automatic_failover_enabled = var.multi_az_enabled

  dynamic "log_delivery_configuration" {
    for_each = var.enabled_log_types

    content {
      destination_type = "cloudwatch-logs"
      log_format       = "text"
      log_type         = log_delivery_configuration.value
      destination      = aws_cloudwatch_log_group.elasticache_log_group[log_delivery_configuration.value].name
    }
  }

  tags = merge(local.default_tags, var.tags)
}

# Use cluster for existing Redis deployments and Memcached.
resource "aws_elasticache_cluster" "this" {
  count = local.use_replication_group ? 0 : 1

  cluster_id           = var.cluster_id
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = local.cluster_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.this.name
  security_group_ids   = [aws_security_group.this.id]
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  apply_immediately    = var.apply_modification_updates_immediately

  # Note: auth_token is only configured on replication groups.

  dynamic "log_delivery_configuration" {
    for_each = var.engine == "redis" ? var.enabled_log_types : []

    content {
      destination_type = "cloudwatch-logs"
      log_format       = "text"
      log_type         = log_delivery_configuration.value
      destination      = aws_cloudwatch_log_group.elasticache_log_group[log_delivery_configuration.value].name
    }
  }

  tags = merge(local.default_tags, var.tags)
}
