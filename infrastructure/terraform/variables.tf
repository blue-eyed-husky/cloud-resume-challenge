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
  default     = null
}

variable "subdomain_name" {
  description = "The subdomain name for the website (e.g., www)."
  type        = string
  default     = "resume"
}

variable "ACM certificate_arn" {
  description = "The ARN of the ACM certificate for the domain."
  type        = string
  default     = null
}