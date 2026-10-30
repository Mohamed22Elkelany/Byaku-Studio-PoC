locals {
  module_name       = "tf-aws/security-hub"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_standards_subscription" "this" {
  count         = var.standards_arns != null ? length(var.standards_arns) : 0
  standards_arn = var.standards_arns[count.index]

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_finding_aggregator" "this" {
  count = var.enable_aggregation == true ? 1 : 0

  linking_mode      = var.linking_mode
  specified_regions = var.specified_regions != null ? var.specified_regions : null

  depends_on = [aws_securityhub_account.this]
}