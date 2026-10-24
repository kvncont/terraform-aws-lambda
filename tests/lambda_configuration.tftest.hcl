mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/test-lambda"
    }
  }

  mock_resource "aws_lambda_function" {
    defaults = {
      arn = "arn:aws:lambda:us-east-1:123456789012:function:test-dev"
    }
  }
}

mock_provider "archive" {}

variables {
  tags = {
    environment = "test"
    managed_by  = "terraform"
    owner       = "platform-team"
  }
  region        = "us-east-1"
  function_name = "test"
  runtime       = "python3.14"
  environment   = "dev"
}

run "defaults" {
  command = plan

  assert {
    condition = (
      aws_lambda_function.this.timeout == 3 &&
      aws_lambda_function.this.memory_size == 128 &&
      length(aws_lambda_function.this.layers) == 0 &&
      length(aws_lambda_function.this.vpc_config) == 0 &&
      length(aws_security_group.lambda) == 0 &&
      length(aws_iam_role_policy_attachment.vpc) == 0 &&
      length(aws_cloudwatch_metric_alarm.lambda) == 0
    )
    error_message = "Defaults must preserve Lambda settings without VPC or alarms."
  }
}

run "managed_vpc_and_alarms" {
  command = apply

  variables {
    timeout                  = 30
    memory_size              = 512
    layers                   = ["arn:aws:lambda:us-east-1:123456789012:layer:utilities:1"]
    enable_cloudwatch_alarms = true
    alarm_actions            = ["arn:aws:sns:us-east-1:123456789012:lambda-alerts"]
    vpc_config = {
      vpc_id     = "vpc-12345678"
      subnet_ids = ["subnet-12345678"]
    }
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
  }

  assert {
    condition = (
      aws_lambda_function.this.timeout == 30 &&
      aws_lambda_function.this.memory_size == 512 &&
      length(aws_lambda_function.this.layers) == 1 &&
      contains(aws_lambda_function.this.vpc_config[0].security_group_ids, aws_security_group.lambda[0].id) &&
      length(aws_iam_role_policy_attachment.vpc) == 1 &&
      length(aws_vpc_security_group_ingress_rule.lambda) == 1 &&
      length(aws_vpc_security_group_egress_rule.lambda) == 1
    )
    error_message = "Lambda must use the configured sizing, layers, VPC, and security group rules."
  }

  assert {
    condition = (
      length(aws_cloudwatch_metric_alarm.lambda) == 3 &&
      aws_cloudwatch_metric_alarm.lambda["errors"].threshold == 1 &&
      aws_cloudwatch_metric_alarm.lambda["throttles"].statistic == "Sum" &&
      aws_cloudwatch_metric_alarm.lambda["duration"].threshold == 24000 &&
      aws_cloudwatch_metric_alarm.lambda["duration"].extended_statistic == "p95" &&
      alltrue([for alarm in aws_cloudwatch_metric_alarm.lambda :
        alarm.dimensions["FunctionName"] == "lambda-test-dev" &&
        alarm.treat_missing_data == "notBreaching" &&
        contains(alarm.alarm_actions, "arn:aws:sns:us-east-1:123456789012:lambda-alerts")
      ])
    )
    error_message = "Alarms must monitor the Lambda with correct thresholds, dimensions, and notification actions."
  }
}

run "separate_kms_keys" {
  command = plan

  variables {
    source_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/11111111-1111-1111-1111-111111111111"
    kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/22222222-2222-2222-2222-222222222222"
  }

  assert {
    condition = (
      aws_lambda_function.this.source_kms_key_arn == var.source_kms_key_arn &&
      aws_lambda_function.this.kms_key_arn == var.kms_key_arn &&
      length(aws_iam_role_policy.kms) == 1 &&
      toset(jsondecode(aws_iam_role_policy.kms[0].policy).Statement[0].Resource) == toset([var.source_kms_key_arn, var.kms_key_arn])
    )
    error_message = "Lambda must use independent KMS keys and grant decrypt access only to those keys."
  }
}

run "custom_alarm_settings" {
  command = plan

  variables {
    enable_cloudwatch_alarms = true
    cloudwatch_alarms = {
      errors = {
        metric_name         = "Errors"
        threshold           = 5
        period              = 60
        evaluation_periods  = 3
        datapoints_to_alarm = 2
        alarm_actions       = []
      }
      throttles = {
        metric_name = "Throttles"
        threshold   = 1
        enabled     = false
      }
      duration = {
        metric_name = "Duration"
        statistic   = "Maximum"
        threshold   = 2000
      }
    }
  }

  assert {
    condition = (
      length(aws_cloudwatch_metric_alarm.lambda) == 2 &&
      aws_cloudwatch_metric_alarm.lambda["errors"].threshold == 5 &&
      aws_cloudwatch_metric_alarm.lambda["errors"].period == 60 &&
      aws_cloudwatch_metric_alarm.lambda["errors"].evaluation_periods == 3 &&
      aws_cloudwatch_metric_alarm.lambda["errors"].datapoints_to_alarm == 2 &&
      length(aws_cloudwatch_metric_alarm.lambda["errors"].alarm_actions) == 0 &&
      aws_cloudwatch_metric_alarm.lambda["duration"].statistic == "Maximum" &&
      aws_cloudwatch_metric_alarm.lambda["duration"].extended_statistic == null &&
      aws_cloudwatch_metric_alarm.lambda["duration"].threshold == 2000
    )
    error_message = "Alarm configuration must apply thresholds, disable individual alarms, and support statistics."
  }
}

run "remove_rules" {
  command = plan

  variables {
    vpc_config = {
      vpc_id     = "vpc-12345678"
      subnet_ids = ["subnet-12345678"]
    }
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.lambda) == 0 && length(aws_vpc_security_group_egress_rule.lambda) == 0
    error_message = "Empty rule maps must remove all managed security group rules."
  }
}

run "existing_security_groups" {
  command = plan

  variables {
    vpc_config = {
      vpc_id                = "vpc-12345678"
      subnet_ids            = ["subnet-12345678"]
      security_group_ids    = ["sg-12345678"]
      create_security_group = false
    }
  }

  assert {
    condition = (
      length(aws_security_group.lambda) == 0 &&
      contains(aws_lambda_function.this.vpc_config[0].security_group_ids, "sg-12345678") &&
      length(aws_iam_role_policy_attachment.vpc) == 1
    )
    error_message = "Existing security groups must be attached without creating a new group."
  }
}

run "invalid_timeout" {
  command = plan
  variables {
    timeout = 901
  }
  expect_failures = [var.timeout]
}

run "invalid_memory" {
  command = plan
  variables {
    memory_size = 127
  }
  expect_failures = [var.memory_size]
}

run "too_many_layers" {
  command = plan
  variables {
    layers = [for i in range(6) : "arn:aws:lambda:us-east-1:123456789012:layer:layer-${i}:1"]
  }
  expect_failures = [var.layers]
}

run "invalid_vpc" {
  command = plan
  variables {
    vpc_config = {
      vpc_id                = "vpc-12345678"
      subnet_ids            = []
      create_security_group = false
    }
  }
  expect_failures = [var.vpc_config]
}

run "rules_without_managed_group" {
  command = plan
  variables {
    security_group_egress_rules = {
      https = {
        protocol  = "tcp"
        from_port = 443
        to_port   = 443
        cidr_ipv4 = "10.0.0.0/16"
      }
    }
  }
  expect_failures = [aws_lambda_function.this]
}
