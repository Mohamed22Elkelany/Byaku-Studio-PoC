locals {
  module_name       = "tf-aws/instance"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Alventara"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

resource "aws_instance" "this" {

  ami           = var.ami_id
  instance_type = var.instance_type

  # Security
  key_name                = var.keypair_name
  iam_instance_profile    = aws_iam_instance_profile.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  disable_api_stop        = var.disable_api_stop
  disable_api_termination = var.disable_api_termination

  # Networking
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = var.subnet_id
  metadata_options {
    http_tokens = "required"
  }

  # Storage
  root_block_device {
    volume_size           = var.root_block_device.size
    volume_type           = var.root_block_device.type
    encrypted             = var.root_block_device.encrypted
    delete_on_termination = var.root_block_device.delete_on_termination
  }

  # General
  tags = merge(local.default_tags, var.tags, {
    Name = var.instance_name
  })
}
