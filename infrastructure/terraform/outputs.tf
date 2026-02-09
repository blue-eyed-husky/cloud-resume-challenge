output "bucket_name" {
  value = aws_s3_bucket.resume_bucket.id
}

output "bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.resume_bucket_website.website_endpoint
}

output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.resume_bucket_website.website_endpoint}"
}
