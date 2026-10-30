locals {
  sub_module_name       = "tf-aws/load-balancer/listener"
  sub_module_version    = file("${path.module}/RELEASE")
  sub_module_maintainer = "Cloud Softway"
  default_tags = {
    SubModuleName       = local.sub_module_name
    SubModuleVersion    = local.sub_module_version
    SubModuleMaintainer = local.sub_module_maintainer
  }
}
