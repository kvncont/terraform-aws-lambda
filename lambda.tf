data "archive_file" "artifact" {
  type        = "zip"
  source_file = "${path.module}/lambda/${local.function_dir}/${local.function_file}"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "this" {
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.this,
    aws_iam_role_policy_attachment.vpc,
    aws_iam_role_policy.kms
  ]

  filename           = "lambda_function.zip"
  function_name      = var.function_name
  role               = aws_iam_role.this.arn
  runtime            = var.runtime
  handler            = local.function_handler
  source_code_hash   = data.archive_file.artifact.output_base64sha256
  timeout            = var.timeout
  memory_size        = var.memory_size
  layers             = var.layers
  tags               = var.tags
  source_kms_key_arn = var.source_kms_key_arn
  kms_key_arn        = var.kms_key_arn

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]

    content {
      subnet_ids = vpc_config.value.subnet_ids
      security_group_ids = concat(
        tolist(vpc_config.value.security_group_ids),
        aws_security_group.lambda[*].id
      )
    }
  }

  lifecycle {
    precondition {
      condition = (
        length(var.security_group_ingress_rules) == 0 && length(var.security_group_egress_rules) == 0
      ) || (var.vpc_config == null ? false : var.vpc_config.create_security_group)
      error_message = "Security group rules require vpc_config with create_security_group enabled."
    }

    ignore_changes = [
      handler,
      filename,
      source_code_hash
    ]
  }
}

resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = "NONE"
}
