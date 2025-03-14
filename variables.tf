variable "region" {
  type = string
  description = "AWS Region"
  default = "us-east-1"
}

variable "function_name" {
  type = string
  description = ""
  default = "my-app-1"
}

variable "function_handler" {
  type = string
  description = ""
  default = "lambda_function.lambda_handler"
}