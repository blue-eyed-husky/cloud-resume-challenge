# Establish locals **removed S3 website origin for better security, using CloudFront instead**
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

# # Create S3 bucket policy
# resource "aws_s3_bucket_policy" "resume_bucket_policy" {
#   bucket = aws_s3_bucket.resume_bucket.id

#   depends_on = [aws_s3_bucket_public_access_block.resume_bucket_public_access]

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "PublicReadGetObject"
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = "s3:GetObject"
#         Resource  = "${aws_s3_bucket.resume_bucket.arn}/*"
#       }
#     ]
#   })
# }

# set S3 bucket policy with Cloudfront read permissions
data "aws_iam_policy_document" "resume_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resume_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.resume_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.id
  policy = data.aws_iam_policy_document.resume_bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.resume_bucket_public_access]
}

# Set S3 public access block
resource "aws_s3_bucket_public_access_block" "resume_bucket_public_access" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# # Static website hosting confirugation **removed for better security, using CloudFront instead**
# resource "aws_s3_bucket_website_configuration" "resume_bucket_website" {
#   bucket = aws_s3_bucket.resume_bucket.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }

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

# GitHub Deploy Permission
data "aws_iam_policy_document" "github_deploy_permissions" {
  # Needed for `aws s3 sync` (ListObjectsV2)
  statement {
    sid     = "S3ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.resume_bucket.arn
    ]
  }

  # Needed to upload/delete objects during sync
  statement {
    sid    = "S3ObjectRW"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectTagging",
      "s3:DeleteObjectTagging"
    ]
    resources = [
      "${aws_s3_bucket.resume_bucket.arn}/*"
    ]
  }

  # Needed to make changes show immediately (cache invalidation)
  statement {
    sid     = "CloudFrontInvalidation"
    effect  = "Allow"
    actions = ["cloudfront:CreateInvalidation"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_deploy_inline" {
  name   = "github-deploy-inline"
  role   = aws_iam_role.github_deploy_role.id
  policy = data.aws_iam_policy_document.github_deploy_permissions.json
}
