locals {
  module_name       = "aws-tf/load-balancer"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName    = local.module_name
    ModuleVersion = local.module_version
  }
}

resource "aws_lb" "this" {
  name               = var.load_balancer_name
  load_balancer_type = var.load_balancer_type
  internal           = var.load_balancer_internal
  security_groups    = var.security_group_ids
  subnets            = var.eips == null ? var.subnets : null

  dynamic "subnet_mapping" {
    for_each = var.eips != null ? { for idx, subnet_id in var.subnets : idx => { subnet_id = subnet_id, eip_id = var.eips[idx] } } : {}

    content {
      subnet_id     = subnet_mapping.value.subnet_id
      allocation_id = subnet_mapping.value.eip_id
    }
  }

  tags = merge(var.tags, local.default_tags, { Name = var.load_balancer_name })
}

# resource "aws_security_group" "load_balancer" {
#   name        = "${var.load_balancer_name}-sg"
#   description = "Security group for the ${var.load_balancer_name} load balancer"
#   vpc_id      = var.vpc_id

#   dynamic "ingress" {
#     for_each = var.ingress_rules
#     iterator = item

#     content {
#       from_port       = item.value.from_port
#       to_port         = item.value.to_port
#       protocol        = item.value.protocol
#       cidr_blocks     = length(item.value.cidr_blocks) > 0 ? item.value.cidr_blocks : null
#       security_groups = length(item.value.security_groups) > 0 ? item.value.security_groups : null
#       prefix_list_ids = length(item.value.prefix_list_ids) > 0 ? item.value.prefix_list_ids : null
#       description     = item.value.description
#     }
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outbound traffic"
#   }

#   tags = merge(var.tags, local.default_tags, { Name = "${var.load_balancer_name}-sg" })
# }

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
