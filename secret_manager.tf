resource "aws_secretsmanager_secret" "this" {
  count       = var.secret_nanager_enabled ? 1 : 0
  name        = "scrm-${local.function_name}"
  description = "Secret for ${local.function_name}"
  kms_key_id  = var.secrets_manager_kms_key_id
}
