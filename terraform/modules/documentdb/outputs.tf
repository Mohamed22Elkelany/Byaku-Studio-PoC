output "cluster_id" {
  description = "The ID of the DocumentDB cluster."
  value       = aws_docdb_cluster.this.id
}

output "endpoint" {
  description = "The endpoint of the DocumentDB cluster."
  value       = aws_docdb_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "The reader endpoint of the DocumentDB cluster."
  value       = aws_docdb_cluster.this.reader_endpoint
}

output "parameter_group_name" {
  value = aws_docdb_cluster_parameter_group.this.name
}
