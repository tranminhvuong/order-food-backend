locals {
  domain_name = var.domain_name
  project     = var.project
  environment = var.environment
}

resource "aws_cloudfront_distribution" "alb_distribution" {
  origin {
    domain_name = local.domain_name
    origin_id   = local.domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = false
  comment         = "${local.project} ${local.environment} distribution"

  # AWS Managed Caching Polify (CachingDisabled)
  default_cache_behavior {
    # Using the CachingDisabled managed policy ID:
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    viewer_protocol_policy = "redirect-to-https"
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.domain_name
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_200"
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
