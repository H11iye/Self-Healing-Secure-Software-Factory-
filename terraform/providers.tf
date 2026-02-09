terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Replace these with an existing bucket or create one manually first
  # backend "s3" {
  #   bucket         = "your-unique-terraform-state-bucket"
  #   key            = "devsecops-factory/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-lock"
  # }
}

provider "aws" {
  region = "us-east-1"
}