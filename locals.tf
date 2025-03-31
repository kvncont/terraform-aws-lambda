locals {
  app_name         = regex("(.*)-[^-]+$", var.waypoint_application)[0]
  app_role_name    = "LambdaExecutionRoleFor${replace(title(local.app_name), "-", "")}"
  function_dir     = can(regex("python", var.runtime)) ? "python" : "nodejs"
  function_file    = local.function_dir == "python" ? "lambda_function.py" : "index.mjs"
  function_handler = local.function_dir == "python" ? "lambda_function.handler" : "index.handler"
}
