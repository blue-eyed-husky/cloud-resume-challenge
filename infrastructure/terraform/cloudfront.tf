# S3 origin for CloudFront **removed S3 website origin for better security**
# locals {
#   s3_website_origin = "${var.s3_bucket_name}.s3-website-us-west-1.amazonaws.com"
# }

# CloudFront distribution
resource "aws_cloudfront_distribution" "resume_distribution" {
  aliases = [var.domain_name]
  origin {
    domain_name              = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin-${var.s3_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.resume_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "mitchell-resume.com CloudFront Distribution"
  default_root_object = "index.html"

  # Cache behavior configuration
  default_cache_behavior {
    target_origin_id       = "s3-origin-${var.s3_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # Custom error response to serve index.html for 403 errors (useful for SPA routing)
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  # ACM cert for HTTPS
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Cho Resume CloudFront Distribution"
  }
}

# Cloudfront origin access control
resource "aws_cloudfront_origin_access_control" "resume_oac" {
  name                              = "resume-oac"
  description                       = "OAC for resume site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}