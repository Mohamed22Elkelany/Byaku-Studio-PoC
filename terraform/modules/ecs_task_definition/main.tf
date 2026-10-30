locals {
  module_name       = "tf-aws/ecs-task-definition"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }

  secrets_list = flatten([
    for secret_arn in var.secret_arns : [
      for key in var.secret_keys : {
        name      = key
        valueFrom = "${secret_arn}:${key}::"
      } if !contains(var.exclude_secret_keys, key)
    ]
  ])

  environment_list = [
    for key, value in var.environment_variables : {
      name  = key
      value = value
    }
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.name}"
  retention_in_days = 90
  log_group_class   = "STANDARD"
  tags              = merge(local.default_tags, var.tags)
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn


  container_definitions = jsonencode([
    merge({
      name      = var.container_name
      image     = "${var.repo_name}:${var.container_image_tag}"
      cpu       = tonumber(var.cpu)
      memory    = tonumber(var.memory)
      essential = true
      portMappings = var.container_port != null ? [
        merge({
          containerPort = var.container_port
          protocol      = "tcp"
          }, var.host_port != null ? {
          hostPort = var.host_port
          } : {}
        )
      ] : []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.log_group_region
          awslogs-stream-prefix = "ecs"
        }
      }
      secrets     = local.secrets_list
      environment = local.environment_list

      linuxParameters = {
        initProcessEnabled = true
      }
      }, var.container_command != null ? { command = var.container_command } : {},
      var.health_check != null ? {
        healthCheck = {
          command     = var.health_check.command
          interval    = var.health_check.interval
          timeout     = var.health_check.timeout
          retries     = var.health_check.retries
          startPeriod = var.health_check.start_period
        }
      } : {},
    var.stop_timeout != null ? { stopTimeout = var.stop_timeout } : {})
  ])

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }
  dynamic "volume" {
    for_each = var.enable_efs ? [1] : []
    content {
      name = "efs_media"
      efs_volume_configuration {
        file_system_id = var.efs_file_system_id
        root_directory = var.efs_root_directory
      }
    }
  }
  tags = merge(local.default_tags, var.tags)
}
