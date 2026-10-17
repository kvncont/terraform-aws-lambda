output "security_group_id" {
  description = "Security group created for the VPC-attached Lambda"
  value       = module.lambda.security_group_id
}
