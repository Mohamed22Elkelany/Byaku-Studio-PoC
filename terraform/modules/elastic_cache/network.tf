resource "aws_elasticache_subnet_group" "this" {
  name        = "${var.cluster_id}-subnet-group"
  description = var.subnet_group_description
  subnet_ids  = var.ealstic_cache_subnet_ids

  tags = merge(local.default_tags, var.tags, { Name = "${var.cluster_id}-subnet-group" })
}
