data "archive_file" "artifact" {
  type        = "zip"
  source_file = "${path.module}/lambda/${local.function_dir}/${local.function_file}"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "app" {
  filename         = "lambda_function.zip"
  function_name    = var.waypoint_application
  role             = aws_iam_role.app.arn
  runtime          = var.runtime
  handler          = local.function_handler
  source_code_hash = data.archive_file.artifact.output_base64sha256

  lifecycle {
    ignore_changes = [
      handler,
      filename,
      source_code_hash
    ]
  }
}

resource "aws_lambda_function_url" "app" {
  function_name      = aws_lambda_function.app.function_name
  authorization_type = "NONE"
}
