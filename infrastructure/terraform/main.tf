# Establish locals 
locals {
  frontend_dir = coalesce(var.frontend_directory, "${path.module}/../../frontend")
  site_files   = fileset(local.frontend_dir, "**/*")
  content_types = {
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif"  = "image/gif",
    "svg"  = "image/svg+xml",
    "json" = "application/json",
    "ico"  = "image/x-icon",
    "txt"  = "text/plain",
    "pdf"  = "application/pdf",
  }
}

# Create S3 bucket for hosting the resume
resource "aws_s3_bucket" "resume_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "Cho Resume Bucket"
  }
}

# Create S3 bucket policy
resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.resume_bucket_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.resume_bucket.arn}/*"
      }
    ]
  })
}

# Set S3 public access block
resource "aws_s3_bucket_public_access_block" "resume_bucket_public_access" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Static website hosting confirugation
resource "aws_s3_bucket_website_configuration" "resume_bucket_website" {
  bucket = aws_s3_bucket.resume_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# upload frontend files to S3 bucket
resource "aws_s3_object" "resume_files" {
  for_each = toset(local.site_files)

  bucket = aws_s3_bucket.resume_bucket.id
  key    = each.value
  source = "${local.frontend_dir}/${each.value}"

  content_type = lookup(
    local.content_types,
    lower(try(regexall("\\.([a-zA-Z0-9]+)$", each.value)[0][0], "")),
    "application/octet-stream"
  )

  etag = filemd5("${local.frontend_dir}/${each.value}")
}
