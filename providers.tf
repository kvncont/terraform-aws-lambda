terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}
