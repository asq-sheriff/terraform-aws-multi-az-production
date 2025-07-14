terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # Placeholder: Replace with your own S3 bucket and DynamoDB table details
    bucket         = "asq-tfstate-storage-01"                 # Replace with your bucket name
    key            = "projects/vpc-project/terraform.tfstate" # Replace with your state file key
    region         = "us-east-1"                              # Replace if using a different region
    dynamodb_table = "asq-terraform-locks"                    # Replace with your DynamoDB table for locking
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  availability_zones   = ["us-east-1a", "us-east-1b"]
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24"]
}