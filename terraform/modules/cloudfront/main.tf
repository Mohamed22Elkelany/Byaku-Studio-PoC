locals {
  module_name                     = "tf-aws/cloudfront"
  module_version                  = file("${path.module}/RELEASE")
  module_maintainer               = "Cloud Softway"
  origin_request_policy_index_map = { for idx, name in var.managed_origin_request_policy_names : name => idx }
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }
}

module "cache_policy" {

  count = length([for behavior in var.cache_behaviors : behavior if behavior.cache_policy_name == null])

  source = "./cache_policy"

  name                 = var.cache_behaviors[count.index].cache_policy.name
  comment              = var.cache_behaviors[count.index].cache_policy.comment
  default_ttl          = var.cache_behaviors[count.index].cache_policy.default_ttl
  max_ttl              = var.cache_behaviors[count.index].cache_policy.max_ttl
  min_ttl              = var.cache_behaviors[count.index].cache_policy.min_ttl
  cookies_config       = var.cache_behaviors[count.index].cache_policy.cookies_config
  headers_config       = var.cache_behaviors[count.index].cache_policy.headers_config
  query_strings_config = var.cache_behaviors[count.index].cache_policy.query_strings_config
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = var.enabled
  aliases         = var.aliases
  comment         = var.comment
  is_ipv6_enabled = var.is_ipv6_enabled
  web_acl_id      = var.web_acl_id != null ? var.web_acl_id : null
  price_class     = var.price_class
  http_version    = "http2and3"

  origin {
    domain_name              = var.domain_name
    origin_id                = var.origin_id
    origin_access_control_id = var.origin_type == "s3" ? aws_cloudfront_origin_access_control.this[0].id : null

    dynamic "custom_header" {
      for_each = var.custom_headers != null ? var.custom_headers : null
      content {
        name  = custom_header.key
        value = custom_header.value
      }
    }

    dynamic "s3_origin_config" {
      for_each = var.origin_type == "s3" ? [1] : []
      content {
        origin_access_identity = ""
      }
    }

    dynamic "custom_origin_config" {
      for_each = var.origin_type == "custom" ? [1] : []
      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = var.origin_protocol_policy
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    compress                 = var.cache_behaviors[0].compress
    allowed_methods          = var.cache_behaviors[0].allowed_methods
    cached_methods           = var.cache_behaviors[0].cached_methods
    target_origin_id         = var.target_origin_id
    viewer_protocol_policy   = var.cache_behaviors[0].viewer_protocol_policy
    cache_policy_id          = var.cache_behaviors[0].cache_policy_name != null ? var.managed_cache_policy_ids[var.cache_behaviors[0].cache_policy_name] : module.cache_policy[0].policy_id
    origin_request_policy_id = var.cache_behaviors[0].origin_request_policy_name != null ? data.aws_cloudfront_origin_request_policy.managed[local.origin_request_policy_index_map[var.cache_behaviors[0].origin_request_policy_name]].id : null
  }

  dynamic "ordered_cache_behavior" {
    iterator = index
    for_each = toset(range(1, length(var.cache_behaviors)))

    content {
      path_pattern             = var.cache_behaviors[index.value].path_pattern
      compress                 = var.cache_behaviors[index.value].compress
      allowed_methods          = var.cache_behaviors[index.value].allowed_methods
      cached_methods           = var.cache_behaviors[index.value].cached_methods
      target_origin_id         = var.target_origin_id
      viewer_protocol_policy   = var.cache_behaviors[index.value].viewer_protocol_policy
      cache_policy_id          = var.cache_behaviors[index.value].cache_policy_name != null ? var.managed_cache_policy_ids[var.cache_behaviors[index.value].cache_policy_name] : module.cache_policy[index.value].policy_id
      origin_request_policy_id = var.cache_behaviors[index.value].origin_request_policy_name != null ? data.aws_cloudfront_origin_request_policy.managed[local.origin_request_policy_index_map[var.cache_behaviors[index.value].origin_request_policy_name]].id : null
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.ssl_support_method
    minimum_protocol_version       = var.minimum_protocol_version
  }

  tags = merge(local.default_tags, var.tags)

  depends_on = [module.cache_policy]
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  count = var.origin_type == "s3" ? 1 : 0

  name                              = coalesce(var.origin_access_control_name, "${var.origin_id}-oac")
  description                       = "Origin access control for ${var.origin_id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_origin_request_policy" "managed" {
  count = length(var.managed_origin_request_policy_names)
  name  = var.managed_origin_request_policy_names[count.index]
}
