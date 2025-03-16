terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.assume_role_arn
  }
  default_tags {
    tags = {
      Owner     = "Platform Team"
      CreatedBy = "Terraform"
    }
  }
}
