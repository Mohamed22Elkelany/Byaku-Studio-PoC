# Required application secrets. Terraform owns the secret
# containers only; values are set outside Terraform by the application team and
# never enter Terraform state. Each ECS execution role can read only the
# secrets mapped to its service (see ecs_iam.tf).
locals {
  app_secret_suffixes = [
    "database-url",
    "admin-database-url",
    "jwt-secret",
    "admin-jwt-secret",
    "agent-token-pepper",
    "field-encryption-key",
    "admin-field-encryption-key",
    "internal-api-secret",
  ]
}

resource "aws_secretsmanager_secret" "app" {
  for_each = toset(local.app_secret_suffixes)

  name                    = "${local.name}/${each.value}"
  description             = "Byaku ${var.environment_name} ${each.value} (value managed outside Terraform)"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = merge(local.default_tags, var.tags)
}
