locals {
  module_name       = "tf-aws/ecs-cluster-asg"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName        = local.module_name
    ModuleVersion     = local.module_version
    module_maintainer = local.module_maintainer
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"

  }

  tags = merge(local.default_tags, var.tags)
}


resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create_capacity_provider ? 1 : 0

  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this[0].name]

  dynamic "default_capacity_provider_strategy" {
    for_each = var.enable_default_capacity_provider ? [1] : []
    content {
      base              = 1
      weight            = 100
      capacity_provider = aws_ecs_capacity_provider.this[0].name
    }
  }
}

resource "aws_ecs_capacity_provider" "this" {
  count = var.create_capacity_provider ? 1 : 0

  name = "${var.cluster_name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.auto_scaling_group_arn
    managed_termination_protection = var.protect_from_scale_in ? "ENABLED" : "DISABLED"

    dynamic "managed_scaling" {
      for_each = var.enable_managed_scaling ? [1] : []

      content {
        maximum_scaling_step_size = var.maximum_scaling_step_size
        minimum_scaling_step_size = var.minimum_scaling_step_size
        status                    = "ENABLED"
        target_capacity           = var.asg_target_capacity_utilization
      }
    }
  }

  tags = merge(local.default_tags, var.tags)
}


resource "aws_service_discovery_http_namespace" "this" {
  name        = "${var.cluster_name}-namespace"
  description = "A discovery instance for the ${var.cluster_name}."

  tags = merge(local.default_tags, var.tags)
}


