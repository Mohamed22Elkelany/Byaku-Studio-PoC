locals {
  module_name       = "tf-aws/ecs-cluster-fargate"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  dynamic "configuration" {
    for_each = var.configuration_enabled ? [1] : []
    content {
      execute_command_configuration {
        kms_key_id = var.kms_key_id

        log_configuration {
          cloud_watch_encryption_enabled = var.cloud_watch_encryption_enabled
          cloud_watch_log_group_name     = var.cloud_watch_log_group_name
          s3_bucket_name                 = var.s3_bucket_name
          s3_bucket_encryption_enabled   = var.s3_bucket_encryption_enabled
          s3_key_prefix                  = var.s3_key_prefix
        }

        logging = var.logging
      }

      managed_storage_configuration {
        fargate_ephemeral_storage_kms_key_id = var.fargate_ephemeral_storage_kms_key_id
        kms_key_id                           = var.managed_storage_kms_key_id
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.service_connect_enabled ? [1] : []
    content {
      namespace = aws_service_discovery_http_namespace.this.arn
    }
  }

  // Optional: Cluster settings
  dynamic "setting" {
    for_each = var.settings
    content {
      name  = setting.value["name"]
      value = setting.value["value"]
    }
  }

  tags = merge(local.default_tags, var.tags)
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = var.capacity_providers

  default_capacity_provider_strategy {
    capacity_provider = var.default_capacity_provider
    weight            = var.default_capacity_provider_weight
    base              = var.default_capacity_provider_base
  }
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = "${var.cluster_name}-namespace"
  description = "A discovery instance for the ${var.cluster_name}."

  tags = merge(local.default_tags, var.tags)
}
