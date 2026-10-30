###########################################################################
# The Byaku-Studio-PoC account has no organization-managed GuardDuty detector,
# so the account detector is created here.
###########################################################################

module "guardduty" {
  source = "./modules/guard_duty"

  guardduty_enabled = var.guardduty_enabled

  tags = merge(local.default_tags, var.tags)
}
