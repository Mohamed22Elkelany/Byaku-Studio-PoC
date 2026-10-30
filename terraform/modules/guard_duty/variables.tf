variable "guardduty_enabled" {
  description = "Enable or disable GuardDuty"
  type        = bool
  default     = true
}

variable "tags" {
  description = <<-EOT
    Tags to be added to the provisioned infrastructure.
  EOT
  type        = map(string)
  default     = {}
}


