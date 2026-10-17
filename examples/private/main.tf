terraform {
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
      test = "value"
    }
  }
}

module "lambda" {
  source = "../.."

  function_name = "lambda-private-example"
  runtime       = "python3.13"

  vpc_config = {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  security_group_egress_rules = {
    internal_https = {
      description = "HTTPS to internal VPC services"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = var.vpc_cidr
    }
  }

  tags = var.tags
}
