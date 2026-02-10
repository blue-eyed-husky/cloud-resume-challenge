terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary
provider "aws" {
  region = var.aws_region
}

# For ACM
provider "aws_acm" {
  alias  = "aws_acm"
  region = var.aws_region_acm
}