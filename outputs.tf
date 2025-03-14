output "function_url" {
  value = resource.aws_lambda_function_url.lambda.function_url
  description = "Lambda function URL"
}