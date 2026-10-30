output "elasticache_cluster_id" {
  description = "The ID of the ElastiCache cluster."
  value       = local.use_replication_group ? aws_elasticache_replication_group.this[0].id : aws_elasticache_cluster.this[0].id
}

output "elasticache_endpoint" {
  description = "The DNS name of the cache cluster without the port appended"
  value       = local.use_replication_group ? aws_elasticache_replication_group.this[0].primary_endpoint_address : aws_elasticache_cluster.this[0].cache_nodes[0].address
}

output "elasticache_port" {
  description = "The port number on which the cache accepts connections"
  value       = local.use_replication_group ? var.redis_port : aws_elasticache_cluster.this[0].cache_nodes[0].port
}
