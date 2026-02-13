variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-1"
}

variable "aws_region_acm" {
  description = "The AWS region for ACM (Certificate Manager)."
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for storing resume files."
  type        = string
  default     = "cho-resume-bucket"
}

variable "frontend_directory" {
  description = "Path to the frontend directory."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name for the website (e.g., example.com)."
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the domain."
  type        = string
}

# Github thumbprint
variable "github_oidc_thumbprint" {
  description = "The ACM certificate thumbprint for github.com (used for ACM validation)."
  type        = list(any)
}

variable "github_owner" {
  description = "The GitHub repository owner (used for ACM validation)."
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name (used for ACM validation)."
  type        = string
}

variable "github_branch" {
  description = "The GitHub repository branch (used for ACM validation)."
  type        = string
  default     = "main"
}
variable "visitor_table_name" {
  description = "Name of the DynamoDB table for visitor tracking."
  type        = string
  default     = "resume_visitors"
}

