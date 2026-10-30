locals {
  module_name       = "tf-aws/launch-template"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

data "aws_caller_identity" "this" {}

resource "aws_iam_role" "this" {
  name = var.iam_instance_profile_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(var.iam_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.this.name
}

resource "aws_launch_template" "this" {
  name_prefix             = var.launch_template_name != "" ? var.launch_template_name : "asg-template"
  image_id                = var.image_id
  instance_type           = var.instance_type
  key_name                = var.key_name != "" ? var.key_name : null
  user_data               = var.user_data != "" ? base64encode(var.user_data) : null
  vpc_security_group_ids  = var.vpc_security_group_ids
  disable_api_stop        = var.disable_api_stop
  disable_api_termination = var.disable_api_termination

  monitoring {
    enabled = var.enable_monitoring
  }

  metadata_options {
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = 1
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings != null ? var.block_device_mappings : []

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      ebs {
        snapshot_id           = try(block_device_mappings.value.snapshot_id, null)
        volume_size           = try(block_device_mappings.value.volume_size, null)
        volume_type           = try(block_device_mappings.value.volume_type, null)
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, null)
        encrypted             = try(block_device_mappings.value.encrypted, null)
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
      }
    }
  }


  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != "" ? [1] : []
    content {
      name = aws_iam_instance_profile.this.name
    }
  }

  dynamic "instance_market_options" {
    for_each = var.use_spot_instance ? [1] : []
    content {
      market_type = "spot"

      spot_options {
        max_price                      = var.spot_max_price
        spot_instance_type             = var.spot_instance_type
        instance_interruption_behavior = "terminate"
      }
    }
  }

  dynamic "private_dns_name_options" {
    for_each = var.private_dns_name_options != null ? [true] : []
    content {
      enable_resource_name_dns_a_record    = try(var.private_dns_name_options.enable_resource_name_dns_a_record, null)
      enable_resource_name_dns_aaaa_record = try(var.private_dns_name_options.enable_resource_name_dns_aaaa_record, null)
      hostname_type                        = try(var.private_dns_name_options.private_dns_name_options, null)
    }
  }

  tags = merge(local.default_tags, var.tags)
  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
}
