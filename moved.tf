moved {
  from = aws_iam_role.app
  to   = aws_iam_role.this
}

moved {
  from = aws_iam_role_policy_attachment.app
  to   = aws_iam_role_policy_attachment.this
}

moved {
  from = aws_lambda_function.app
  to   = aws_lambda_function.this
}

moved {
  from = aws_lambda_function_url.app
  to   = aws_lambda_function_url.this
}
