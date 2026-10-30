output "cluster_id" {
  description = "The ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "The ECS cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "The ECS cluster name"
  value       = aws_ecs_cluster.this.name
}
output "http_namespace_arn" {
  description = "The ECS cluster ARN"
  value       = aws_service_discovery_http_namespace.this.arn
}

output "http_namespace_id" {
  description = "The ECS cluster ARN"
  value       = aws_service_discovery_http_namespace.this.id
}

output "http_namespace_name" {
  description = "The ECS cluster ARN"
  value       = aws_service_discovery_http_namespace.this.http_name
}
