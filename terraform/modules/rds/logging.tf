##############################################
###          CloudWatch Log Group          ###
##############################################

resource "aws_cloudwatch_log_group" "this" {
  for_each = toset(var.enabled_cloudwatch_logs_exports)

  name              = "/aws/rds/instance/${var.identifier}/${each.value}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = merge(local.default_tags, var.tags)
}

##############################################
###          Enhanced Monitoring           ###
##############################################

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  name                 = "${var.identifier}-enhanced-monitoring-iam-role"
  assume_role_policy   = data.aws_iam_policy_document.enhanced_monitoring.json
  description          = "Monitoring IAM role for the RDS ${var.identifier}"
  permissions_boundary = var.monitoring_role_permissions_boundary

  tags = merge(local.default_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
