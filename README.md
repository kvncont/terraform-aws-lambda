## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.91.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.91.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_function_url) | resource |
| [archive_file.artifact](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | ARN Role that Terraform assume | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime environment for the Lambda function | `string` | n/a | yes |
| <a name="input_waypoint_application"></a> [waypoint\_application](#input\_waypoint\_application) | Name of the application | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_runtime"></a> [function\_runtime](#output\_function\_runtime) | Runtime environment for the Lambda function |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | Lambda function URL |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN Role for the Lambda function |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | Role name for the Lambda function |
