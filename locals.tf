locals {
  lambda_name = replace(title(var.function_name),"-","")
  role_name = "LambdaExecutionRoleFor${local.lambda_name}"
  policy_name = "CustomPolicyFor${local.lambda_name}"
}