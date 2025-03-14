variable "region" {
  type = string
  description = "AWS Region"
  default = "us-east-1"
}

variable "function_name" {
  type = string
  description = "Name of the Lambda function"
}

variable "function_handler" {
  type = string
  description = "Entry point for the Lambda function handler"
  default = "lambda_function.lambda_handler"
}