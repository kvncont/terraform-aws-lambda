resource "aws_secretsmanager_secret" "this" {
  name        = "scrm-${local.function_name}"
  description = "Secret for ${local.function_name}"
  kms_key_id  = var.secrets_manager_kms_key_id
}
