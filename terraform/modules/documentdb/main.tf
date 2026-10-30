locals {
  module_name       = "tf-aws/documentdb"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_docdb_cluster_parameter_group" "this" {
  name   = var.parameter_group_name != null ? var.parameter_group_name : "${var.cluster_identifier}-pg"
  family = var.parameter_group_family # Adjust family based on your DocumentDB version


  tags = merge(local.default_tags, var.tags, {
    Name = "${var.cluster_identifier}"
  })
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

}

resource "aws_docdb_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.cluster_identifier}"
  })
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier              = var.cluster_identifier
  master_username                 = var.db_username
  master_password                 = var.db_password
  backup_retention_period         = var.backup_retention_period
  db_subnet_group_name            = aws_docdb_subnet_group.this.name
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name
  skip_final_snapshot             = true
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
  tags = merge(local.default_tags, var.tags, {
    Name = var.cluster_identifier
  })
}
resource "aws_docdb_cluster_instance" "this" {
  for_each                     = tomap(var.instances)
  identifier                   = "${var.cluster_identifier}-${each.key}"
  cluster_identifier           = aws_docdb_cluster.this.id
  instance_class               = var.documentdb_config.instance_class
  availability_zone            = each.value.availability_zone
  preferred_maintenance_window = var.preferred_maintenance_window
  tags = merge(local.default_tags, var.tags, {
    Name = var.cluster_identifier
  })
}