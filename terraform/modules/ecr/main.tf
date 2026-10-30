locals {
  module_name       = "tf-aws/ecr"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_ecr_repository" "this" {
  count = var.enabled ? 1 : 0

  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.image_scanning
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  tags = merge(local.default_tags, var.tags)
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.enabled && var.lifecycle_policy != null ? 1 : 0

  repository = aws_ecr_repository.this[0].name
  policy     = var.lifecycle_policy
}

