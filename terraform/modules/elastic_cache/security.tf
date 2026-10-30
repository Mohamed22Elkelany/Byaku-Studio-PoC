resource "aws_security_group" "this" {
  name        = "${var.cluster_id}-sg"
  description = "Security Group for the Elastic Cache to allow Elastic Cache traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = item

    content {
      description = item.value.description
      from_port   = item.value.from_port
      to_port     = item.value.to_port
      protocol    = item.value.protocol

      cidr_blocks     = length(item.value.cidr_blocks) > 0 ? item.value.cidr_blocks : null
      security_groups = length(item.value.security_groups) > 0 ? item.value.security_groups : null
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    iterator = item

    content {
      description = item.value.description
      from_port   = item.value.from_port
      to_port     = item.value.to_port
      protocol    = item.value.protocol
      cidr_blocks = item.value.cidr_blocks
    }
  }

  tags = merge(local.default_tags, var.tags, { Name = "${var.cluster_id}-sg" })
}
