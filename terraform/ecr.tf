# Application image repositories: <project>-<environment_name>/<service>,
# e.g. byaku-poc/backend. Tags are
# immutable (gha-<sha12>-<run>-<attempt>) and deployments use digests.
module "ecr" {
  for_each = toset(var.ecr.repository_names)

  source = "./modules/ecr"

  enabled              = true
  repository_name      = "${local.name}/${each.value}"
  image_tag_mutability = var.ecr.image_tag_mutability
  image_scanning       = var.ecr.image_scanning
  encryption_type      = "AES256"
  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Retain the newest ${var.ecr.keep_images} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr.keep_images
      }
      action = { type = "expire" }
    }]
  })

  tags = merge(local.default_tags, var.tags)
}
