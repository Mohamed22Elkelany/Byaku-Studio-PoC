# default_tags applies local.default_tags (including the aws-apn-id partner tag)
# to every taggable resource created through these providers, including those
# inside modules. Resource-level tags are merged on top.
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias   = "secondary"
  region  = var.secondary_region
  profile = var.aws_profile

  default_tags {
    tags = local.default_tags
  }
}

# provider "awscc" {
#   region     = var.primary_region
#   access_key = var.access_key
#   secret_key = var.secret_key
# }

# provider "awscc" {
#   alias = "secondary"

#   region     = var.secondary_region
#   access_key = var.access_key
#   secret_key = var.secret_key
# }
