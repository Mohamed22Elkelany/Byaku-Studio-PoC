locals {
  module_name       = "tf-aws/guard-duty"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}


# Enable GuardDuty for the current account
resource "aws_guardduty_detector" "this" {
  enable = var.guardduty_enabled

  tags = merge(local.default_tags, var.tags)
}
