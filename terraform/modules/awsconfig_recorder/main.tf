locals {
  module_name       = "tf-aws/awsconfig-recorder"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_config_configuration_recorder" "this" {
  name     = var.name
  role_arn = aws_iam_role.this.arn

  recording_group {
    all_supported = var.all_supported

    dynamic "exclusion_by_resource_types" {
      for_each = var.excluded_resource_types != null ? [true] : []
      content {
        resource_types = [var.excluded_resource_types.value]
      }
    }

    dynamic "recording_strategy" {
      for_each = var.recording_strategy != null ? [true] : []
      content {
        use_only = var.recording_strategy
      }
    }
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = "${var.name}-delivery-channel"
  s3_bucket_name = var.s3_bucket_name
  depends_on     = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-iam-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
  }
}