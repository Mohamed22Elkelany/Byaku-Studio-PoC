# Task definitions and services. Terraform registers the initial revision of every family with a bootstrap image tag; the
# CD pipeline then describes the family, swaps in the released image digest and
# registers new revisions, so Terraform ignores task_definition/desired_count
# drift on the services.
locals {
  internal_url = { for svc, port in local.ecs_service_ports : svc => "http://${svc}.${local.internal_namespace}:${port}" }

  node_health_check = {
    for svc in ["web", "admin-web", "backend", "integrations"] : svc => [
      "CMD", "node", "-e",
      "fetch('http://127.0.0.1:${local.ecs_service_ports[svc]}/health',{signal:AbortSignal.timeout(4000)}).then(r=>process.exit(r.status===200?0:1)).catch(()=>process.exit(1))",
    ]
  }

  web_environment = {
    AWS_REGION       = var.aws_region
    HOSTNAME         = "0.0.0.0"
    INTERNAL_API_URL = local.internal_url["backend"]
    LIVE_LLM         = "false"
    NODE_ENV         = "production"
    PORT             = "3000"
  }

  # Bedrock is out of scope for the PoC: add local.bedrock_layer_models,
  # ANTHROPIC_TRANSPORT = "bedrock" and BEDROCK_REGION back with bedrock.tf.
  backend_environment = {
    ADMIN_AUTH_BYPASS_ENABLED = "false"
    ADMIN_DATABASE_POOL_MAX   = "5"
    ADMIN_PUBLIC_URL          = "https://${var.app_hostnames.admin}"
    AGENT_API_PUBLIC_URL      = "https://${var.app_hostnames.api}"
    AI_LABS_FOUR_EYES_ENABLED = "false"
    AI_SERVICE_URL            = local.internal_url["ai"]
    APP_PUBLIC_URL            = "https://${var.app_hostnames.app}"
    AWS_REGION                = var.aws_region
    CORS_ORIGIN               = "https://${var.app_hostnames.app}"
    EMAIL_FROM                = "Byaku Studio <no-reply@${trimprefix(var.acm_certificate_domain, "*.")}>"
    EVIDENCE_STORAGE_ROOT     = "/usr/src/app/storage/evidence-files"
    INTEGRATIONS_SERVICE_URL  = local.internal_url["integrations"]
    LIVE_LLM                  = var.live_llm
    MAIL_PROVIDER             = "ses"
    NODE_ENV                  = "production"
    OAUTH_CALLBACK_BASE_URL   = "https://${var.app_hostnames.api}"
    PORT                      = "4000"
    RAW_ARTIFACT_ROOT         = "/usr/src/app/storage/raw-artifacts"
    REPORT_S3_BUCKET          = "${local.name}-reports-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
    REPORT_S3_PREFIX          = "reports/"
    REPORT_S3_REGION          = var.aws_region
    REPORT_STORAGE_BACKEND    = "s3"
    SES_CONFIGURATION_SET     = "${local.name}-transactional"
    SES_REGION                = var.aws_region
    TRUST_PROXY_CIDRS         = var.vpc_cidr
  }

  # Every task family: default sizing, image repository, roles and
  # container settings. Per-environment sizing comes from var.ecs_task_sizes.
  ecs_task_families = {
    web = {
      cpu         = 512, memory = 1024, repo = "web", role = "web", log_group = "web", stream = "application"
      port        = 3000, health_check = local.node_health_check["web"], stop_timeout = 30, command = null, user = null, read_only = null, drop_caps = false
      environment = merge(local.web_environment, { BYAKU_WEB_SURFACE = "customer" })
      secrets     = {}
      task_role   = true, data_class = "internal"
    }
    admin-web = {
      cpu         = 512, memory = 1024, repo = "admin-web", role = "admin-web", log_group = "admin-web", stream = "application"
      port        = 3000, health_check = local.node_health_check["admin-web"], stop_timeout = 30, command = null, user = null, read_only = null, drop_caps = false
      environment = merge(local.web_environment, { BYAKU_WEB_SURFACE = "admin" })
      secrets     = {}
      task_role   = true, data_class = "internal"
    }
    backend = {
      cpu         = 1024, memory = 2048, repo = "backend", role = "backend", log_group = "backend", stream = "application"
      port        = 4000, health_check = local.node_health_check["backend"], stop_timeout = 30, command = null, user = null, read_only = null, drop_caps = false
      environment = local.backend_environment
      secrets     = local.app_secret_env.backend
      task_role   = true, data_class = "internal"
    }
    ai = {
      cpu          = 256, memory = 512, repo = "ai", role = "ai", log_group = "ai", stream = "application"
      port         = 8000, stop_timeout = 30, command = null, user = null, read_only = null, drop_caps = false
      health_check = ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health',timeout=4)"]
      environment = {
        AWS_REGION       = var.aws_region
        LIVE_LLM         = "false"
        NODE_ENV         = "production"
        PORT             = "8000"
        PYTHONUNBUFFERED = "1"
      }
      secrets   = {}
      task_role = true, data_class = "internal"
    }
    integrations = {
      cpu  = 256, memory = 512, repo = "integrations", role = "integrations", log_group = "integrations", stream = "application"
      port = 4100, health_check = local.node_health_check["integrations"], stop_timeout = null, command = null, user = null, read_only = null, drop_caps = false
      environment = {
        API_URL     = local.internal_url["backend"]
        AWS_REGION  = var.aws_region
        CORS_ORIGIN = local.internal_url["backend"]
        LIVE_LLM    = "false"
        NODE_ENV    = "production"
        PORT        = "4100"
      }
      secrets   = local.app_secret_env.integrations
      task_role = true, data_class = "internal"
    }
    db-migrate = {
      cpu         = 256, memory = 512, repo = "db-migrate", role = "migration", log_group = "db-migrate", stream = "migration"
      port        = null, health_check = null, stop_timeout = null, command = null, user = null, read_only = null, drop_caps = false
      environment = {}
      secrets     = local.app_secret_env["db-migrate"]
      task_role   = true, data_class = "restricted"
    }
    admin-db-migrate = {
      cpu         = 256, memory = 512, repo = "admin-db-migrate", role = "migration", log_group = "admin-db-migrate", stream = "migration"
      port        = null, health_check = null, stop_timeout = null, command = null, user = null, read_only = null, drop_caps = false
      environment = {}
      secrets     = local.app_secret_env["admin-db-migrate"]
      task_role   = true, data_class = "restricted"
    }
    # Post-rollout private smoke test, run by the CD pipeline from the web image.
    private-smoke = {
      cpu         = 256, memory = 512, repo = "web", role = "web", log_group = "web", stream = "release-smoke"
      port        = null, health_check = null, stop_timeout = null, command = ["node", "release-smoke.mjs"], user = "10001:10001", read_only = true, drop_caps = true
      environment = {}
      secrets     = {}
      task_role   = false, data_class = "internal"
    }
  }
}

resource "aws_ecs_task_definition" "app" {
  for_each = local.ecs_task_families

  family                   = "${local.name}-${each.key}"
  cpu                      = try(var.ecs_task_sizes[each.key].cpu, each.value.cpu)
  memory                   = try(var.ecs_task_sizes[each.key].memory, each.value.memory)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution[each.value.role].arn
  task_role_arn            = each.value.task_role ? aws_iam_role.ecs_task[each.value.role].arn : null

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  dynamic "ephemeral_storage" {
    for_each = try(var.ecs_task_sizes[each.key].ephemeral_storage, null) == null ? [] : [var.ecs_task_sizes[each.key].ephemeral_storage]
    content {
      size_in_gib = ephemeral_storage.value
    }
  }

  container_definitions = jsonencode([merge(
    {
      name      = each.key == "private-smoke" ? "private-smoke" : each.key
      image     = "${module.ecr[each.value.repo].repository_url}:bootstrap"
      essential = true
      environment = [
        for name in sort(keys(each.value.environment)) : { name = name, value = each.value.environment[name] }
      ]
      secrets = [
        for name in sort(keys(each.value.secrets)) : { name = name, valueFrom = aws_secretsmanager_secret.app[each.value.secrets[name]].arn }
      ]
      portMappings = each.value.port == null ? [] : [{ containerPort = each.value.port, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app[each.value.log_group].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = each.value.stream
        }
      }
    },
    each.value.health_check == null ? {} : {
      healthCheck = { command = each.value.health_check, interval = 30, timeout = 5, retries = 3, startPeriod = 60 }
    },
    each.value.stop_timeout == null ? {} : { stopTimeout = each.value.stop_timeout },
    each.value.command == null ? {} : { command = each.value.command },
    each.value.user == null ? {} : { user = each.value.user },
    each.value.read_only == null ? {} : { readonlyRootFilesystem = each.value.read_only },
    each.value.drop_caps ? { linuxParameters = { capabilities = { add = [], drop = ["ALL"] }, initProcessEnabled = true } } : {},
  )])

  # Environment and ReleaseAuthority must match what the CD role requires when
  # it re-registers revisions from this template.
  tags = merge(local.default_tags, var.tags, {
    Environment      = var.environment_name
    ReleaseAuthority = "ByakuReleaseRunner"
    DataClass        = each.value.data_class
  })
}

###########################################
##               Services                ##
###########################################
locals {
  # Services exposed through the public ALB (target group per service).
  alb_services = {
    web       = { host = var.app_hostnames.app, priority = 10 }
    admin-web = { host = var.app_hostnames.admin, priority = 20 }
    backend   = { host = var.app_hostnames.api, priority = 30 }
  }

  ecs_target_groups = { for svc, tg in aws_lb_target_group.app : svc => tg.arn }
}

resource "aws_ecs_service" "app" {
  for_each = local.ecs_service_ports

  name             = "${local.name}-${each.key}"
  cluster          = module.ecs_cluster.cluster_arn
  task_definition  = aws_ecs_task_definition.app[each.key].arn
  desired_count    = lookup(var.ecs_desired_count, each.key, 0)
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = contains(keys(local.ecs_target_groups), each.key) ? 60 : null

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = module.vpc.private_subnet_ids_by_tier["app"]
    security_groups  = [aws_security_group.app[each.key].id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app[each.key].arn
  }

  dynamic "load_balancer" {
    for_each = contains(keys(local.ecs_target_groups), each.key) ? [1] : []
    content {
      target_group_arn = local.ecs_target_groups[each.key]
      container_name   = each.key
      container_port   = each.value
    }
  }

  tags = merge(local.default_tags, var.tags, {
    Environment = var.environment_name
  })

  lifecycle {
    # Rollouts (task definition revisions) and scaling belong to the CD pipeline.
    ignore_changes = [task_definition, desired_count]
  }

  depends_on = [aws_lb_listener_rule.app]
}
