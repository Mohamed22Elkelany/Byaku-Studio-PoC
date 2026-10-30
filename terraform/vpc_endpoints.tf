# Gateway endpoint: keeps S3 traffic (including ECR image layers) off the NAT gateways at no cost.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.project}-s3-endpoint-${var.environment}"
  })
}

# Interface endpoints (e.g. ECR API/DKR, CloudWatch Logs) for private workloads.
module "vpc_endpoints_sg" {
  count = length(var.vpc_interface_endpoints) > 0 ? 1 : 0

  source      = "./modules/security_group"
  description = "Security group for the ${var.project} VPC interface endpoints"
  vpc_id      = module.vpc.vpc_id
  name        = "${var.project}-vpc-endpoints-sg-${var.environment}"
  ingress_rules = [
    {
      description = "Allow HTTPS from within the VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  ]
  tags = merge(local.default_tags, var.tags)
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.vpc_interface_endpoints)

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  # Interface endpoints accept a single subnet per AZ, so use the app tier only.
  subnet_ids         = module.vpc.private_subnet_ids_by_tier["app"]
  security_group_ids = [module.vpc_endpoints_sg[0].security_group_id]

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.project}-${replace(each.value, ".", "-")}-endpoint-${var.environment}"
  })
}
