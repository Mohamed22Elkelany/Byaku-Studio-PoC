resource "aws_db_subnet_group" "this" {

  name       = "${lower(var.identifier)}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.default_tags, var.tags, { Name = "${var.identifier}-subnet-group" })
}
