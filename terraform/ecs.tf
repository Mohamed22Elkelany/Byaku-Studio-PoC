# ECS layout: cluster, private service discovery (byaku.internal), per-service
# log groups and security groups. Task definitions/services are in ecs_tasks.tf and IAM in
# ecs_iam.tf.
locals {
  # Long-running services and their container ports.
  ecs_service_ports = {
    web          = 3000
    admin-web    = 3000
    backend      = 4000
    ai           = 8000
    integrations = 4100
  }

  # Log groups: one per service plus the two migration families.
  app_log_groups = toset(concat(keys(local.ecs_service_ports), ["db-migrate", "admin-db-migrate"]))

  internal_namespace = "byaku.internal"
}

# Capacity providers can only be attached once the ECS service-linked role
# exists, so create it explicitly instead of racing its implicit creation.
resource "aws_iam_service_linked_role" "ecs" {
  count = var.ecs_cluster.create_service_linked_role ? 1 : 0

  aws_service_name = "ecs.amazonaws.com"
  tags             = merge(local.default_tags, var.tags)
}

module "ecs_cluster" {
  source                    = "./modules/ecs_cluster_fargate"
  cluster_name              = "${local.name}-cluster"
  capacity_providers        = var.ecs_cluster.capacity_providers
  default_capacity_provider = var.ecs_cluster.default_capacity_provider
  settings = [
    {
      name  = "containerInsights"
      value = var.ecs_cluster.container_insights
    }
  ]
  tags = merge(local.default_tags, var.tags)

  depends_on = [aws_iam_service_linked_role.ecs]
}

###########################################
##        Service discovery              ##
###########################################
# Services reach each other privately, e.g. http://backend.byaku.internal:4000.
resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = local.internal_namespace
  description = "Private service discovery for ${local.name}"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "app" {
  for_each = local.ecs_service_ports

  name = each.key

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }
}

###########################################
##             Log groups                ##
###########################################
resource "aws_cloudwatch_log_group" "app" {
  for_each = local.app_log_groups

  name              = "/${local.name}/${each.value}"
  retention_in_days = var.app_log_retention_in_days
  kms_key_id        = aws_kms_key.logs.arn
}

###########################################
##           Security groups             ##
###########################################
resource "aws_security_group" "app" {
  for_each = toset(concat(keys(local.ecs_service_ports), ["migration", "release-smoke"]))

  name        = "${local.name}-${each.value}"
  description = "Byaku ${var.environment_name} ${each.value} tasks"
  vpc_id      = module.vpc.vpc_id

  tags = { Name = "${local.name}-${each.value}" }
}

resource "aws_vpc_security_group_egress_rule" "app" {
  for_each = aws_security_group.app

  security_group_id = each.value.id
  description       = "Outbound to AWS APIs, databases and peers"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

locals {
  # Allowed callers per service.
  app_ingress = {
    "web-from-alb"              = { service = "web", source = module.alb_sg.security_group_id }
    "admin-web-from-alb"        = { service = "admin-web", source = module.alb_sg.security_group_id }
    "backend-from-alb"          = { service = "backend", source = module.alb_sg.security_group_id }
    "backend-from-web"          = { service = "backend", source = aws_security_group.app["web"].id }
    "backend-from-admin-web"    = { service = "backend", source = aws_security_group.app["admin-web"].id }
    "ai-from-backend"           = { service = "ai", source = aws_security_group.app["backend"].id }
    "integrations-from-backend" = { service = "integrations", source = aws_security_group.app["backend"].id }
  }
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  for_each = local.app_ingress

  security_group_id            = aws_security_group.app[each.value.service].id
  description                  = each.key
  ip_protocol                  = "tcp"
  from_port                    = local.ecs_service_ports[each.value.service]
  to_port                      = local.ecs_service_ports[each.value.service]
  referenced_security_group_id = each.value.source
}
