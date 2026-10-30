# tfsec:ignore:aws-iam-no-policy-wildcards
# tfsec:ignore:aws-cloudwatch-log-group-customer-key
module "vpc" {
  source = "./modules/vpc"

  vpc_name = "${var.project}-vpc-${var.environment}"
  vpc_cidr = var.vpc_cidr

  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  nat_gateway_mode     = var.nat_gateway_mode
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true

  tags = merge(local.default_tags, var.tags)
}
