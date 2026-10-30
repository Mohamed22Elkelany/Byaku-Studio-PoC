output "load_balancer_arn" {
  description = "The Amazon Resource Name (ARN) of the load balancer."
  value       = aws_lb.this.arn
}

output "load_balancer_id" {
  description = "The ID of the load balancer."
  value       = aws_lb.this.id
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "listeners_arns" {
  description = "A list of ARNs for the listeners associated with the load balancer."
  value       = module.listeners[*].listener_arn
}

output "alb_hosted_zone_id" {
  description = "The Route 53 hosted zone ID associated with the load balancer."
  value       = aws_lb.this.zone_id
}
