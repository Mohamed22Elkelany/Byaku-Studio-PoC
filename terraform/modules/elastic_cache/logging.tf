resource "aws_cloudwatch_log_group" "elasticache_log_group" {
  for_each          = toset(var.enabled_log_types)
  name              = "/aws/elasticache/${var.cluster_id}/${each.key}"
  retention_in_days = var.log_retention_in_days

  tags = merge(local.default_tags, var.tags, { Name = "${var.cluster_id}-log-group" })
}