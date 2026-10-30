output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets created in the VPC."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets created in the VPC."
  value       = aws_subnet.private[*].id
}

output "flow_logs_log_group_name" {
  description = "The ARN of the CloudWatch log group used for VPC flow logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "private_subnet_ids_by_tier" {
  description = "A map of private subnet tier to the list of subnet IDs in that tier."
  value = {
    for tier in distinct(var.private_subnets[*].tier) : tier => [
      for idx, subnet in var.private_subnets : aws_subnet.private[idx].id if subnet.tier == tier
    ]
  }
}

output "private_route_table_ids" {
  description = "A list of IDs for the private route tables (one per AZ)."
  value       = [for rt in aws_route_table.private : rt.id]
}

output "nat_gateway_public_ips" {
  description = "A list of public IPs of the NAT gateways."
  value       = concat([for eip in aws_eip.nat_gateway : eip.public_ip], [for eip in aws_eip.regional_nat : eip.public_ip])
}
