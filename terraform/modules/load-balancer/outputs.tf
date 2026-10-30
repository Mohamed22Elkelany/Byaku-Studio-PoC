output "load_balancer_arn" {
  value = aws_lb.this.arn
}

output "load_balancer_id" {
  value = aws_lb.this.id
}

output "load_balancer_dns_name" {
  value = aws_lb.this.dns_name
}

output "listeners_arns" {
  value = module.listeners[*].listener_arn
}

output "alb_hosted_zone_id" {
  value = aws_lb.this.zone_id
}