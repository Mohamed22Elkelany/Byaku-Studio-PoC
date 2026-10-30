output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids_by_tier" {
  value = module.vpc.private_subnet_ids_by_tier
}

output "nat_gateway_public_ips" {
  description = "Egress IPs of the private subnets (useful for third-party allow-lists)."
  value       = module.vpc.nat_gateway_public_ips
}

output "alb_name" {
  value = "${var.project}-alb-${var.environment}"
}

output "alb_dns_name" {
  description = "Point the Cloudflare DNS record (proxied CNAME) at this name."
  value       = module.alb.load_balancer_dns_name
}

output "alb_security_group_id" {
  value = module.alb_sg.security_group_id
}

output "app_target_group_arns" {
  value = { for svc, tg in aws_lb_target_group.app : svc => tg.arn }
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  value = module.ecs_cluster.cluster_arn
}

output "ecr_repository_urls" {
  value = { for name, repo in module.ecr : name => repo.repository_url }
}

output "ecs_service_names" {
  value = { for svc, s in aws_ecs_service.app : svc => s.name }
}

output "ecs_task_families" {
  value = { for family, td in aws_ecs_task_definition.app : family => td.family }
}

output "app_secret_names" {
  description = "Secrets Manager containers whose values the application team must set."
  value       = [for s in aws_secretsmanager_secret.app : s.name]
}

output "alerting_sns_topic_arn" {
  value = module.cloudwatch_alerts.topic_arn
}

output "guardduty_detector_id" {
  value = module.guardduty.guardduty_detector_id
}

output "cloudtrail_bucket_name" {
  value = module.cloudtrail_s3_bucket.bucket_id
}

output "rds_endpoints" {
  description = "Database endpoints (host:port) per store."
  value       = { for db, m in module.rds : db => m.db_instance_endpoint }
}

output "rds_master_user_secret_arns" {
  description = "RDS-managed master credential secrets (rotation disabled) per store."
  value       = { for db, m in module.rds : db => m.db_instance_master_user_secret_arn }
}

output "acm_certificate_validation_records" {
  description = "CNAME records to add in the byaku-studio.com zone (Cloudflare, DNS only) so the certificate is issued and renewed."
  value = [
    for o in aws_acm_certificate.this.domain_validation_options : {
      name  = o.resource_record_name
      type  = o.resource_record_type
      value = o.resource_record_value
    }
  ]
}

output "acm_certificate_status" {
  value = aws_acm_certificate.this.status
}
