locals {
  module_name       = "tf-aws/ecs-service"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster
  task_definition = var.task_definition

  desired_count                      = var.desired_count
  launch_type                        = var.use_capacity_provider ? null : var.launch_type
  platform_version                   = var.platform_version
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = true
  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = var.enable_circuit_breaker
    rollback = var.circuit_breaker_rollback
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.use_capacity_provider ? [1] : []
    content {
      capacity_provider = var.capacity_provider_name
      weight            = 1
      base              = 0
    }
  }


  # network_configuration {
  #   subnets          = var.subnets
  #   security_groups  = var.security_groups
  #   assign_public_ip = var.assign_public_ip
  # }

  dynamic "network_configuration" {
    for_each = var.subnets != null ? [1] : []
    content {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = lookup(ordered_placement_strategy.value, "field", null)
    }
  }




  dynamic "load_balancer" {
    for_each = var.target_group_arn != "" ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }
  dynamic "service_connect_configuration" {
    for_each = var.enable_service_connect ? [1] : []
    content {
      enabled   = true
      namespace = var.service_connect_namespace

      dynamic "service" {
        for_each = var.services
        content {
          discovery_name        = service.value.discovery_name
          ingress_port_override = service.value.ingress_port_override
          port_name             = service.value.port_name
          dynamic "client_alias" {
            for_each = service.value.client_aliases
            content {
              dns_name = client_alias.value.dns_name
              port     = client_alias.value.port
            }
          }
        }
      }
      log_configuration {
        log_driver = var.service_connect_log_driver
        options    = var.service_connect_log_options

        dynamic "secret_option" {
          for_each = var.service_connect_log_secret_options
          content {
            name       = secret_option.value.name
            value_from = secret_option.value.value_from
          }
        }
      }


    }
  }

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    # Application releases register and deploy immutable task-definition
    # revisions through the CD workflow. Terraform retains service ownership
    # without rolling the service back to its bootstrap revision.
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling.max_capacity
  min_capacity       = var.autoscaling.min_capacity
  resource_id        = "service/${basename(var.cluster)}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_target_tracking" {
  for_each = var.enable_autoscaling ? { for p in var.autoscaling.target_tracking : p.name => p } : {}

  name               = "${var.name}-${each.key}-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.target_value
    scale_in_cooldown  = each.value.scale_in_cooldown
    scale_out_cooldown = each.value.scale_out_cooldown

    dynamic "predefined_metric_specification" {
      for_each = each.value.metric_type != "alb" ? [1] : []
      content {
        predefined_metric_type = (
          each.value.metric_type == "cpu"
          ? "ECSServiceAverageCPUUtilization"
          : "ECSServiceAverageMemoryUtilization"
        )
      }
    }

    dynamic "predefined_metric_specification" {
      for_each = each.value.metric_type == "alb" ? [1] : []
      content {
        predefined_metric_type = "ALBRequestCountPerTarget"
        resource_label = replace(
          replace(each.value.alb_target_group_arn,
          "arn:aws:elasticloadbalancing:", ""),
          ":targetgroup/", "/"
        )
      }
    }
  }
}



