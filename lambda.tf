data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = "lambda_function.zip"
  function_name = var.function_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = var.function_handler

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      MY_VAR = "bar"
    }
  }
}

resource "aws_lambda_function_url" "lambda" {
  function_name      = aws_lambda_function.app.function_name
  authorization_type = "NONE"
}
