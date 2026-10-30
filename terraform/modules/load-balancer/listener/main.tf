locals {
  sub_module_name    = "terraform-accelerator/load-balancer/listener"
  sub_module_version = file("${path.module}/RELEASE")
  default_tags = {
    SubModuleName    = local.sub_module_name
    SubModuleVersion = local.sub_module_version
  }
}
