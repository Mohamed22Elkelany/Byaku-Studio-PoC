output "listener_arn" {
  value = aws_lb_listener.this.arn
}

output "protocol" {
  value = var.protocol
}

