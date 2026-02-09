variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-1"
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
