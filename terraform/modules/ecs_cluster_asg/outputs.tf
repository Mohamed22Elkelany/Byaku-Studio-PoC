output "id" {
  description = "ID of the Cluster"
  value       = aws_ecs_cluster.this.id
}

output "name" {
  description = "ID of the Cluster"
  value       = aws_ecs_cluster.this.name
}

output "arn" {
  description = "ID of the Cluster"
  value       = aws_ecs_cluster.this.arn
}

output "capacity_provider_name" {
  value = try(aws_ecs_capacity_provider.this[0].name, null)
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
