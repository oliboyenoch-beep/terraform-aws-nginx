terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
# Remove or comment out this block in backend-setup.tf
# provider "aws" {
#   region = "us-east-1"
# }
