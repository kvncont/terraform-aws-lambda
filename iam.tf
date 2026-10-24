resource "aws_iam_role" "this" {
  name = "iam-role-${var.function_name}"
  tags = var.tags
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Principal : {
          Service : "lambda.amazonaws.com"
        }
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count = var.vpc_config == null ? 0 : 1

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "kms" {
  count = var.source_kms_key_arn != null || var.kms_key_arn != null ? 1 : 0

  name = "LambdaKMSDecrypt"
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["kms:Decrypt"]
      Resource = distinct(compact([var.source_kms_key_arn, var.kms_key_arn]))
    }]
  })
}

resource "aws_iam_role_policy_attachment" "extra" {
  for_each   = var.extra_policies
  role       = aws_iam_role.this.name
  policy_arn = each.value

  lifecycle {
    precondition {
      condition     = can(regex("^arn:aws:iam::[0-9]{12}:policy/platform/approved/", each.value))
      error_message = "The policy must be under /platform/approved/."
    }
  }
}
