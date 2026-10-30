locals {
  module_name       = "zammit-infra/secret_manager"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName    = local.module_name
    ModuleVersion = local.module_version
    aws-apn-id    = "pc:eb8k8df55lxcvpywxg7hnl9p0"
  }
}

# tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = var.secret_description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(local.default_tags, var.tags)
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.create_secret_version ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string != null ? var.secret_string : jsonencode(var.secret_values)
}

