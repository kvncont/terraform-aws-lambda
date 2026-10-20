terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      test = "test-tag"
    }
  }
}

module "lambda" {
  source = "../.."

  function_name = "lambda-public-example"
  runtime       = "python3.13"
  tags          = var.tags

  extra_policies = {
    ddb_orders_read      = "arn:aws:iam::123456789012:policy/platform/approved/pol-ddb-orders-read"
    elc_products_connect = "arn:aws:iam::123456789012:policy/platform/approved/pol-elc-products-connect"
  }
}
