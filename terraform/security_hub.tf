module "security_hub" {
  source = "./modules/security_hub"

  enable_aggregation = var.security_hub.enable_aggregation
  standards_arns     = var.security_hub.standards_arns

  # Security Hub controls evaluate AWS Config resource recordings.
  depends_on = [module.aws_config_recorder]
}
