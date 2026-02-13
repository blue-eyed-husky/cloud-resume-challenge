output "bucket_name" {
  value = aws_s3_bucket.resume_bucket.id
}

# output "bucket_website_endpoint" {
#   value = aws_s3_bucket_website_configuration.resume_bucket_website.website_endpoint
# }

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.resume_bucket.arn
}

# output "website_url" {
#   value = "http://${aws_s3_bucket_website_configuration.resume_bucket_website.website_endpoint}"
# }

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.resume_distribution.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.resume_distribution.id
}

output "site_url" {
  value = "https://${var.domain_name}"
}

output "visitors_api_endpoint" {
  value = aws_apigatewayv2_api.visitors_api.api_endpoint
}