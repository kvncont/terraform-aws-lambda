locals {
  function_dir     = can(regex("python", var.runtime)) ? "python" : "nodejs"
  function_file    = local.function_dir == "python" ? "lambda_function.py" : "index.mjs"
  function_handler = local.function_dir == "python" ? "lambda_function.handler" : "index.handler"
  function_name    = "lambda-${var.function_name}-${var.environment}"
}
