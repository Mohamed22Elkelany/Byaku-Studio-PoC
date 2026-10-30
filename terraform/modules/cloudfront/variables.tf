variable "origin_id" {
  description = "domain name for LB or S3"
  type        = string
}
variable "domain_name" {
  description = "domain name for LB or S3"
  type        = string
}

variable "origin_type" {
  description = "Origin type. Valid values are s3 and custom."
  type        = string
  default     = "custom"

  validation {
    condition     = contains(["s3", "custom"], var.origin_type)
    error_message = "origin_type must be either s3 or custom."
  }
}

variable "origin_access_control_name" {
  description = "Name of the CloudFront origin access control used for an S3 origin."
  type        = string
  default     = null
}

variable "web_acl_id" {
  description = "WAF rule id to be associated with"
  type        = string
  default     = null
}

variable "origin_protocol_policy" {
  description = "Default protocol to use between CloudFront and the custom origin"
  type        = string
}

variable "aliases" {
  description = "List of CNAME aliases to associate with the CloudFront distribution."
  type        = list(string)
}

variable "comment" {
  description = "The description of the CloudFront distribution."
  type        = string
}

variable "is_ipv6_enabled" {
  description = "Boolean flag to indicate whether IPv6 is enabled for the CloudFront distribution."
  type        = bool
}

variable "target_origin_id" {
  description = "The ID of the origin that CloudFront sends traffic to when the path pattern matches the request."
  type        = string
}

variable "restriction_type" {
  description = "geo_restriction type applied to the CloudFront distribution"
  type        = string
}

variable "locations" {
  description = "List of geographic locations where the restriction applies."
  type        = list(string)
}

variable "enabled" {
  description = "Boolean flag to indicate whether the CloudFront distribution is enabled."
  type        = bool
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_All"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate to use for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "ssl_support_method" {
  description = "SSL support method for CloudFront distribution"
  type        = string
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "Minimum SSL/TLS protocol version that CloudFront can use"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "custom_headers" {
  description = "Map of custom headers for CloudFront origin"
  type        = map(string)
  default     = {}
}

variable "managed_cache_policy_ids" {
  description = "Map of predefined managed cache policy IDs corresponding to the cache policy names for use in the CloudFront distribution."
  type        = map(string)
  default = {
    Amplify                                   = "2e54312d-136d-493c-8eb9-b001f22f67d2"
    CachingDisabled                           = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    CachingOptimized                          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    CachingOptimizedForUncompressedObjects    = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
    Elemental-MediaPackage                    = "08627262-05a9-4f76-9ded-b50ca2e3a84f"
    UseOriginCacheControlHeaders              = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    UseOriginCacheControlHeaders-QueryStrings = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
  }
}

variable "managed_origin_request_policy_names" {
  description = "List of predefined managed origin request policy names for use in the CloudFront distribution."
  default = [
    "Managed-AllViewer",
    "Managed-AllViewerAndCloudFrontHeaders-2022-06",
    "Managed-AllViewerExceptHostHeader",
    "Managed-CORS-CustomOrigin",
    "Managed-CORS-S3Origin",
    "Managed-Elemental-MediaTailor-PersonalizedManifests",
    "Managed-UserAgentRefererHeaders"
  ]
}

variable "cache_behaviors" {
  description = "Configurations for cache behaviors."
  type = list(object({
    path_pattern               = optional(string)
    compress                   = bool
    allowed_methods            = list(string)
    cached_methods             = list(string)
    viewer_protocol_policy     = string
    cache_policy_name          = optional(string)
    origin_request_policy_name = optional(string)
    cache_policy = optional(object({
      name         = string
      comment      = string
      default_ttl  = number
      max_ttl      = number
      min_ttl      = number
      allow_gzip   = bool
      allow_brotli = bool
      cookies_config = object({
        behavior = string
        items    = optional(list(string))
      })
      headers_config = object({
        behavior = string
        items    = optional(list(string))
      })
      query_strings_config = object({
        behavior = string
        items    = optional(list(string))
      })
    }))
  }))
}

variable "tags" {
  description = "Tags to be added to the provisioned infrastructure."
  type        = map(string)
  default     = {}
}
