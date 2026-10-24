<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.18 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.amazon_msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.dynamodb_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.kinesis_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_security_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [archive_file.artifact](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | Action ARNs (for example SNS topics) notified when a Lambda alarm enters ALARM | `list(string)` | `[]` | no |
| <a name="input_amazon_msk_event_source_mappings"></a> [amazon\_msk\_event\_source\_mappings](#input\_amazon\_msk\_event\_source\_mappings) | Amazon MSK event source mappings for the Lambda function | <pre>map(object({<br/>    event_source_arn                   = string<br/>    topics                             = set(string)<br/>    batch_size                         = optional(number)<br/>    enabled                            = optional(bool, true)<br/>    maximum_batching_window_in_seconds = optional(number)<br/>    function_response_types            = optional(set(string))<br/>    maximum_record_age_in_seconds      = optional(number)<br/>    maximum_retry_attempts             = optional(number)<br/>    filters = optional(list(object({<br/>      pattern = string<br/>    })), [])<br/>    consumer_group_id = optional(string)<br/>    source_access_configuration = optional(list(object({<br/>      type = string<br/>      uri  = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_cloudwatch_alarms"></a> [cloudwatch\_alarms](#input\_cloudwatch\_alarms) | Complete map of Lambda alarms; replaces the default map. A null Duration threshold uses 80% of timeout in milliseconds | <pre>map(object({<br/>    metric_name               = string<br/>    enabled                   = optional(bool, true)<br/>    threshold                 = optional(number)<br/>    statistic                 = optional(string)<br/>    extended_statistic        = optional(string)<br/>    comparison_operator       = optional(string, "GreaterThanOrEqualToThreshold")<br/>    period                    = optional(number, 300)<br/>    evaluation_periods        = optional(number, 1)<br/>    datapoints_to_alarm       = optional(number)<br/>    treat_missing_data        = optional(string, "notBreaching")<br/>    alarm_actions             = optional(list(string))<br/>    ok_actions                = optional(list(string), [])<br/>    insufficient_data_actions = optional(list(string), [])<br/>  }))</pre> | <pre>{<br/>  "duration": {<br/>    "extended_statistic": "p95",<br/>    "metric_name": "Duration"<br/>  },<br/>  "errors": {<br/>    "metric_name": "Errors",<br/>    "statistic": "Sum",<br/>    "threshold": 1<br/>  },<br/>  "throttles": {<br/>    "metric_name": "Throttles",<br/>    "statistic": "Sum",<br/>    "threshold": 1<br/>  }<br/>}</pre> | no |
| <a name="input_dynamodb_stream_event_source_mappings"></a> [dynamodb\_stream\_event\_source\_mappings](#input\_dynamodb\_stream\_event\_source\_mappings) | DynamoDB Stream event source mappings for the Lambda function | <pre>map(object({<br/>    event_source_arn                   = string<br/>    starting_position                  = string<br/>    batch_size                         = optional(number)<br/>    enabled                            = optional(bool, true)<br/>    maximum_batching_window_in_seconds = optional(number)<br/>    function_response_types            = optional(set(string))<br/>    maximum_record_age_in_seconds      = optional(number)<br/>    maximum_retry_attempts             = optional(number)<br/>    parallelization_factor             = optional(number)<br/>    bisect_batch_on_function_error     = optional(bool)<br/>    tumbling_window_in_seconds         = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_cloudwatch_alarms"></a> [enable\_cloudwatch\_alarms](#input\_enable\_cloudwatch\_alarms) | Create CloudWatch alarms for Lambda errors, throttles, and duration | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for the Lambda function and related resources | `string` | n/a | yes |
| <a name="input_extra_policies"></a> [extra\_policies](#input\_extra\_policies) | Extra IAM policies to attach to the Lambda function | `map(string)` | `{}` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_kinesis_stream_event_source_mappings"></a> [kinesis\_stream\_event\_source\_mappings](#input\_kinesis\_stream\_event\_source\_mappings) | Kinesis Stream event source mappings for the Lambda function | <pre>map(object({<br/>    event_source_arn                   = string<br/>    starting_position                  = string<br/>    batch_size                         = optional(number)<br/>    enabled                            = optional(bool, true)<br/>    starting_position_timestamp        = optional(string)<br/>    maximum_batching_window_in_seconds = optional(number)<br/>    function_response_types            = optional(set(string))<br/>    maximum_record_age_in_seconds      = optional(number)<br/>    maximum_retry_attempts             = optional(number)<br/>    parallelization_factor             = optional(number)<br/>    bisect_batch_on_function_error     = optional(bool)<br/>    tumbling_window_in_seconds         = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Existing customer-managed KMS key ARN for environment variables and other Lambda-managed artifacts; null uses AWS-owned encryption | `string` | `null` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | Ordered list of Lambda layer version ARNs compatible with the function runtime and architecture | `list(string)` | `[]` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | CloudWatch log retention in days; 0 retains logs indefinitely | `number` | `7` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda memory allocation in MB | `number` | `128` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Permissions that allow services or accounts to invoke the Lambda function | <pre>map(object({<br/>    statement_id   = string<br/>    principal      = string<br/>    source_arn     = optional(string)<br/>    source_account = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime environment for the Lambda function | `string` | n/a | yes |
| <a name="input_secret_manager_enabled"></a> [secret\_manager\_enabled](#input\_secret\_manager\_enabled) | Create Secrets Manager for the Lambda function | `bool` | `false` | no |
| <a name="input_secrets_manager_kms_key_id"></a> [secrets\_manager\_kms\_key\_id](#input\_secrets\_manager\_kms\_key\_id) | KMS key ID for the Secrets Manager secret | `string` | `null` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Outbound rules for the managed security group; no outbound access is allowed by default | <pre>map(object({<br/>    description = optional(string)<br/>    protocol    = string<br/>    from_port   = number<br/>    to_port     = number<br/>    cidr_ipv4   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Inbound rules for the managed security group; no inbound access is allowed by default | <pre>map(object({<br/>    description = optional(string)<br/>    protocol    = string<br/>    from_port   = number<br/>    to_port     = number<br/>    cidr_ipv4   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_source_kms_key_arn"></a> [source\_kms\_key\_arn](#input\_source\_kms\_key\_arn) | Existing customer-managed KMS key ARN for Lambda ZIP code encryption; null uses AWS-owned encryption | `string` | `null` | no |
| <a name="input_sqs_queue_event_source_mappings"></a> [sqs\_queue\_event\_source\_mappings](#input\_sqs\_queue\_event\_source\_mappings) | SQS Queue event source mappings, optionally filtered | <pre>map(object({<br/>    event_source_arn                   = string<br/>    batch_size                         = optional(number)<br/>    enabled                            = optional(bool, true)<br/>    maximum_batching_window_in_seconds = optional(number)<br/>    function_response_types            = optional(set(string))<br/>    maximum_concurrency                = optional(number)<br/>    filters = optional(list(object({<br/>      pattern = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Required environment, managed\_by, and owner tags applied explicitly to all module resources that support tagging | <pre>object({<br/>    environment = string<br/>    managed_by  = string<br/>    owner       = string<br/>  })</pre> | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda timeout in seconds | `number` | `3` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Optional VPC attachment; subnets and security groups must belong to vpc\_id | <pre>object({<br/>    vpc_id                = string<br/>    subnet_ids            = set(string)<br/>    security_group_ids    = optional(set(string), [])<br/>    create_security_group = optional(bool, true)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_alarm_arns"></a> [cloudwatch\_alarm\_arns](#output\_cloudwatch\_alarm\_arns) | CloudWatch alarm ARNs keyed by errors, throttles, and duration |
| <a name="output_function_runtime"></a> [function\_runtime](#output\_function\_runtime) | Runtime environment for the Lambda function |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | Lambda function URL |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN Role for the Lambda function |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | Role name for the Lambda function |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Managed Lambda security group ID, or null when not created |
<!-- END_TF_DOCS -->