output "instance_private_ip" {
  description = "Private IP of the Instance"
  value       = aws_instance.this.private_ip
}

output "instance_public_ip" {
  description = "Public IP of the Instance"
  value       = aws_instance.this.public_ip
}

output "instance_id" {
  description = "ID of the Instance"
  value       = aws_instance.this.id
}