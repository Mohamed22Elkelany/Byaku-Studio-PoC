locals {
  module_name       = "tf-aws/autoscaling-group"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = var.name
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = var.target_group_arns
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  default_instance_warmup   = var.default_instance_warmup
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics

  launch_template {
    id      = var.launch_template_id
    version = tostring(var.launch_template_version)
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      instance_warmup        = var.default_instance_warmup
      min_healthy_percentage = 0
      skip_matching          = true
    }

    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = merge(local.default_tags, var.tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
