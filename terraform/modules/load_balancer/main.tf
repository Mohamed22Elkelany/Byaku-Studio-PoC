locals {
  module_name       = "tf-aws/load-balancer"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_lb" "this" {
  name                       = var.load_balancer_name
  load_balancer_type         = var.load_balancer_type
  internal                   = var.load_balancer_internal
  security_groups            = var.security_group_ids
  subnets                    = var.eips == null ? var.subnets : null
  drop_invalid_header_fields = var.drop_invalid_header_fields

  dynamic "subnet_mapping" {
    for_each = var.eips != null ? { for idx, subnet_id in var.subnets : idx => { subnet_id = subnet_id, eip_id = var.eips[idx] } } : {}

    content {
      subnet_id     = subnet_mapping.value.subnet_id
      allocation_id = subnet_mapping.value.eip_id
    }
  }

  tags = merge(var.tags, local.default_tags, { Name = var.load_balancer_name })
}

module "listeners" {

  count = length(var.listeners)

  source = "./listener"

  load_balancer_arn = aws_lb.this.arn
  listener_name     = var.listeners[count.index].name
  port              = var.listeners[count.index].port
  protocol          = var.listeners[count.index].protocol
  certificate_arn   = var.listeners[count.index].certificate_arn
  ssl_policy        = var.listeners[count.index].ssl_policy

  default_action = var.listeners[count.index].default_action
  rules          = var.listeners[count.index].rules

  tags = merge(local.default_tags, var.tags)
}
