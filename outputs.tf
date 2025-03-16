output "lambda_role_arn" {
  value       = aws_iam_role.app.arn
  description = "ARN Role for the Lambda function"
}

output "lambda_role_name" {
  value       = aws_iam_role.app.name
  description = "Role name for the Lambda function"
}

output "function_url" {
  value       = resource.aws_lambda_function_url.app.function_url
  description = "Lambda function URL"
}

output "function_runtime" {
  value       = resource.aws_lambda_function.app.runtime
  description = "Runtime environment for the Lambda function"
}