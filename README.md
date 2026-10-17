## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.69.1 |

## Modules

### Usage examples

- [public](examples/public): basic Lambda without VPC attachment, event source
  mappings, custom KMS keys, layers, or alarms.
- [private](examples/private): Lambda attached to an existing VPC and private
  subnets, with a managed security group and outbound HTTPS to the VPC CIDR.
  No inbound rules are required for normal Lambda invocation.

Both examples configure the AWS provider and default tags in the calling root
module. They also create the module's standard IAM role, log group, and Function
URL. The private example does not create a VPC, subnets, NAT gateways, or
endpoints. VPC attachment does not make the Function URL private; the module
currently creates it with authorization type `NONE` in both examples.

From `examples/public`:

```sh
terraform init
terraform plan -var='assume_role_arn=arn:aws:iam::123456789012:role/terraform'
```

From `examples/private`:

```sh
terraform init
terraform plan \
  -var='assume_role_arn=arn:aws:iam::123456789012:role/terraform' \
  -var='vpc_id=vpc-12345678' \
  -var='subnet_ids=["subnet-12345678","subnet-87654321"]' \
  -var='vpc_cidr=10.0.0.0/16'
```

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.amazon_msk](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.dynamodb_stream](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.kinesis_stream](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.app](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_function_url) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/5.91.0/docs/resources/lambda_permission) | resource |
| [archive_file.artifact](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| source_kms_key_arn | Existing KMS key ARN for ZIP code encryption | `string` | `null` | no |
| kms_key_arn | Existing KMS key ARN for environment variables and Lambda-managed artifacts | `string` | `null` | no |
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | ARN Role that Terraform assume | `string` | n/a | yes |
| <a name="input_amazon_msk_event_source_mappings"></a> [amazon\_msk\_event\_source\_mappings](#input\_amazon_msk\_event\_source\_mappings) | Amazon MSK event source mappings for the Lambda function | `map(object({ ... }))` | `{}` | no |
| <a name="input_dynamodb_stream_event_source_mappings"></a> [dynamodb\_stream\_event\_source\_mappings](#input\_dynamodb_stream\_event\_source\_mappings) | DynamoDB Stream event source mappings for the Lambda function | `map(object({ ... }))` | `{}` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Permissions that allow services or accounts to invoke the Lambda function | `map(object({ statement_id = string, principal = string, source_arn = optional(string), source_account = optional(string) }))` | `{}` | no |
| <a name="input_kinesis_stream_event_source_mappings"></a> [kinesis\_stream\_event\_source\_mappings](#input\_kinesis_stream\_event\_source\_mappings) | Kinesis Stream event source mappings for the Lambda function | `map(object({ ... }))` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime environment for the Lambda function | `string` | n/a | yes |
| <a name="input_sqs_queue_event_source_mappings"></a> [sqs\_queue\_event\_source\_mappings](#input\_sqs\_queue\_event\_source\_mappings) | SQS Queue event source mappings, optionally filtered | `map(object({ ... }))` | `{}` | no |
| <a name="input_function_name"></a> [function_name](#input_function_name) | Name of the Lambda function (1-64 letters, numbers, hyphens, or underscores) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_runtime"></a> [function\_runtime](#output\_function\_runtime) | Runtime environment for the Lambda function |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | Lambda function URL |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN Role for the Lambda function |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | Role name for the Lambda function |

## Optional integrations

### Required resource tags

Set the required `tags` input when calling the module or running this
configuration. All three values must be nonempty:

```hcl
tags = {
  environment = "dev"
  managed_by  = "terraform"
  owner       = "platform-team"
}
```

The module explicitly assigns `tags = var.tags` to Lambda functions,
event source mappings, IAM roles, CloudWatch log groups and alarms, security
groups, and ingress/egress rule resources. The `tags` input has no default and
rejects null, empty, or whitespace-only required values. It does not depend on
the caller configuring provider `default_tags`; explicit resource tags take
precedence over provider defaults with the same keys.

Function URLs, Lambda permissions, inline IAM policies, and IAM policy
attachments do not support tags in AWS and cannot be tagged independently.
Existing external resources, such as KMS keys and VPCs, are not modified.

### Existing KMS keys

The AWS provider constraint `~> 6.18` allows versions >= 6.18.0 and < 7.0.0
to support `source_kms_key_arn`. Run `terraform init -upgrade` to select the
latest compatible 6.x release when a provider lock file already exists.
Review the AWS provider v6 upgrade guide and your Terraform plan before
upgrading an existing deployment.

```hcl
source_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/11111111-1111-1111-1111-111111111111"
kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/22222222-2222-2222-2222-222222222222"
```

Both inputs are optional (`null` by default), accept existing key ARNs, and can
reference the same or different keys. No KMS keys or key policies are created
or modified. Keys must be compatible symmetric encryption keys in the function's
region. `source_kms_key_arn` encrypts the uploaded ZIP code; `kms_key_arn`
encrypts environment variables and can also encrypt other Lambda-managed
artifacts, including the unzipped code when source code encryption is enabled.

The module grants the execution role `kms:Decrypt` only on the supplied keys.
Existing key policies must allow this role to use the keys (or delegate access
through IAM). The deployment identity also needs the applicable KMS permissions
to configure encryption, including grant creation when required by Lambda.
The module does not grant permissions to the deployment identity.

Resource names use `function_name` without requiring an environment suffix.
The IAM execution role uses a generated name prefixed with the first 37
characters of `function_name` to respect IAM's name-prefix length limit.
For existing deployments, review the plan: this naming change replaces the
execution role and updates the Lambda role reference.

### Security group rules

When `vpc_config.create_security_group` is enabled, configure
`security_group_ingress_rules` and `security_group_egress_rules` as maps.
Rules are managed separately using `aws_vpc_security_group_ingress_rule` and
`aws_vpc_security_group_egress_rule`, not inline on the security group.
Only IPv4 targets are supported. Each map entry provides one `cidr_ipv4`
and creates one resource directly, without intermediate locals.
Empty rule maps create no rules.

```hcl
security_group_ingress_rules = {
  internal_https = {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_ipv4 = "10.0.0.0/16"
  }
}

security_group_egress_rules = {
  https = {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_ipv4 = "10.0.0.0/16"
  }
}
```

Replace previous `cidr_blocks` lists with one entry per IPv4 CIDR.
Resource keys now match the map keys; migrate existing Terraform state
addresses before applying to avoid recreating existing rules.

If migrating an existing deployment with inline rules, review the plan and
import existing rules into their new resource addresses before applying;
do not manage the same rules inline and as standalone resources.

### CloudWatch log retention

`log_retention_in_days` controls retention for the Lambda log group and defaults
to 7 days. Use a supported CloudWatch retention period, or `0` to retain logs
indefinitely.

```hcl
log_retention_in_days = 30
```

Applying the default to an existing log group changes its retention to 7 days;
older logs become eligible for deletion.

### CloudWatch alarms

Lambda publishes basic metrics automatically. Set `enable_cloudwatch_alarms`
to create alarms for Errors, Throttles, and Duration. Defaults are:

| Alarm | Statistic | Threshold | Period | Evaluation periods |
|-------|-----------|-----------|--------|--------------------|
| errors | Sum | 1 | 300 seconds | 1 |
| throttles | Sum | 1 | 300 seconds | 1 |
| duration | p95 | 80% of the configured timeout, in milliseconds | 300 seconds | 1 |

All alarms default to `GreaterThanOrEqualToThreshold` and treat missing data as
`notBreaching`. `alarm_actions` provides shared notification action ARNs.
`cloudwatch_alarms` contains the complete alarm map and is used directly,
without locals. Supplying it replaces the default map; omitted alarm entries
are not created. Each entry requires `metric_name`. Optional attributes have
defaults:

```hcl
enable_cloudwatch_alarms = true
alarm_actions           = ["arn:aws:sns:us-east-1:123456789012:lambda-alerts"]

cloudwatch_alarms = {
  errors = {
    metric_name         = "Errors"
    threshold           = 5
    period              = 60
    evaluation_periods  = 3
    datapoints_to_alarm = 2
  }
  throttles = {
    metric_name = "Throttles"
    threshold   = 1
    enabled = false
  }
  duration = {
    metric_name        = "Duration"
    threshold          = 2000
    extended_statistic = "p99"
  }
}
```

Additional per-alarm options are `comparison_operator`, `treat_missing_data`,
`alarm_actions`, `ok_actions`, and `insufficient_data_actions`. The default
statistic is `Sum` unless an `extended_statistic` is supplied. Do not specify
both. Only Duration permits an omitted threshold, which uses 80% of timeout
in milliseconds. An empty `alarm_actions`
list disables notifications for that alarm without disabling the alarm itself.

### Event sources

Pass `permissions` and the event-source-specific maps as module inputs to
create any number of Lambda invocation permissions and event source mappings.
All maps default to empty, so resources are created only for configured entries.

```hcl
permissions = {
  api_gateway = {
    statement_id = "AllowApiGatewayInvoke"
    principal    = "apigateway.amazonaws.com"
    source_arn   = "arn:aws:execute-api:us-east-1:123456789012:api-id/*/*"
  }
}
```

Use one map entry per event source, with distinct variables for each source
type:

```hcl
dynamodb_stream_event_source_mappings = {
  dynamodb = {
    event_source_arn   = "arn:aws:dynamodb:us-east-1:123456789012:table/orders/stream/2026-10-17T00:00:00.000"
    starting_position  = "LATEST"
    batch_size         = 100
  }
}

kinesis_stream_event_source_mappings = {
  kinesis = {
    event_source_arn   = "arn:aws:kinesis:us-east-1:123456789012:stream/orders"
    starting_position  = "TRIM_HORIZON"
    batch_size         = 100
  }
}

sqs_queue_event_source_mappings = {
  orders = {
    event_source_arn = "arn:aws:sqs:us-east-1:123456789012:orders"
    batch_size       = 10
  }
  filtered_orders = {
    event_source_arn = "arn:aws:sqs:us-east-1:123456789012:orders"
    batch_size       = 10
    filters = [{
      pattern = jsonencode({
        body = {
          eventType = ["ORDER_CREATED"]
        }
      })
    }]
  }
}
```

```hcl
amazon_msk_event_source_mappings = {
  msk = {
    event_source_arn = "arn:aws:kafka:us-east-1:123456789012:cluster/orders/abcd1234"
    topics           = ["orders"]
    batch_size       = 100
    source_access_configuration = [{
      type = "SASL_SCRAM_512_AUTH"
      uri  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:msk-credentials"
    }]
  }
}
```

For Amazon MSK, set `event_source_arn` to the cluster ARN and provide one or
more `topics`. Configure `source_access_configuration` as required by the
cluster's authentication and network setup; `consumer_group_id` is optional.

For SQS event filtering, supply one or more filter patterns in `filters`.
Both filtered and unfiltered queues use `sqs_queue_event_source_mappings`;
`filters` is optional.
`starting_position` is required for DynamoDB Streams and Kinesis, but is not
used for SQS or Amazon MSK. The Lambda execution role must also have permission
to read each event source; event source mappings do not grant those IAM
permissions.
