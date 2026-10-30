###########################################################################
# OUT OF SCOPE (commented out): ElastiCache - not part of the current architecture.
###########################################################################

# locals {
#   elastic_cache_listener_port = var.elastic_cache.create_replication_group ? var.elastic_cache.redis_port : 6379
# }
#
# # tfsec:ignore:aws-cloudwatch-log-group-customer-key
# module "elastic_cache" {
#   source = "./modules/elastic_cache"
#
#   create_replication_group               = var.elastic_cache.create_replication_group
#   cluster_id                             = "${var.project}-elastic-cache-${var.environment}"
#   engine                                 = var.elastic_cache.engine
#   engine_version                         = var.elastic_cache.engine_version
#   vpc_id                                 = module.vpc.vpc_id
#   ealstic_cache_subnet_ids               = module.vpc.private_subnet_ids
#   parameter_group_family                 = var.elastic_cache.parameter_group_family
#   node_type                              = var.elastic_cache.node_type
#   num_cache_nodes                        = var.elastic_cache.num_cache_nodes
#   redis_port                             = local.elastic_cache_listener_port
#   multi_az_enabled                       = var.elastic_cache.multi_az_enabled
#   apply_modification_updates_immediately = var.elastic_cache.apply_modification_updates_immediately
#   auth_token                             = null
#   transit_encryption_enabled             = var.elastic_cache.transit_encryption_enabled
#   at_rest_encryption_enabled             = var.elastic_cache.at_rest_encryption_enabled
#   ingress_rules = concat(var.elastic_cache.ingress_rules,
#     [
#       {
#         description     = "Allow Redis from the application service"
#         from_port       = local.elastic_cache_listener_port
#         to_port         = local.elastic_cache_listener_port
#         protocol        = "tcp"
#         security_groups = [module.ecs_application_sg.security_group_id]
#       },
#       {
#         description     = "Allow Redis from the JumpServer"
#         from_port       = local.elastic_cache_listener_port
#         to_port         = local.elastic_cache_listener_port
#         protocol        = "tcp"
#         security_groups = [module.vpn_sg.security_group_id]
#       }
#   ])
#   egress_rules = var.elastic_cache.egress_rules
#   tags         = merge(local.default_tags, var.tags)
# }
