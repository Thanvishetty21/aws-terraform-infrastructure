terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: store state remotely in S3 with DynamoDB locking.
  # Create the bucket/table first, then uncomment and run `terraform init -migrate-state`.
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "aws-terraform-infrastructure/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
