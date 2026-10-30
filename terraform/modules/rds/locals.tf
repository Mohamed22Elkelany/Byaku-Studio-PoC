locals {
  module_name       = "tf-aws/rds"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }

  # Automatically calculate family and major_engine_version from engine and engine_version
  engine_major_version = var.engine == "postgres" ? split(".", var.engine_version)[0] : join(".", slice(split(".", var.engine_version), 0, 2))
  engine_family        = "${var.engine}${local.engine_major_version}"
}
