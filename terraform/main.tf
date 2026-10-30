locals {
  default_tags = {
    aws-apn-id   = "pc:2yqdbavm3n3awa2b98r83k3bd"
    MaintainedBy = "Cloud Softway"
    CreatedBy    = "Terraform"
    Environment  = var.environment
    Project      = var.project
  }

  # Resource prefix shared with the application release tooling, e.g. byaku-poc/...
  name = "${var.project}-${var.environment_name}"
}

data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0, < 7.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.0, < 4.0.0"
    }
  }

  required_version = ">= 1.14.0, < 2.0.0"
}
