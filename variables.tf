variable "tags" {
  description = "Required environment, managed_by, and owner tags applied explicitly to all module resources that support tagging"
  type = object({
    environment = string
    managed_by  = string
    owner       = string
  })
  nullable = false

  validation {
    condition     = alltrue([for value in values(var.tags) : value == null ? false : length(trimspace(value)) > 0])
    error_message = "environment, managed_by, and owner must all have nonempty tag values."
  }
}

variable "environment" {
  description = "Environment for the Lambda function and related resources"
  type        = string
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,58}$", var.function_name))
    error_message = "function_name must contain 1 to 58 letters, numbers, hyphens, or underscores."
  }
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  validation {
    condition     = can(regex("^(python3\\.(10|11|12|13|14)|nodejs(22|24)\\.x)$", var.runtime))
    error_message = "The runtime variable must be one of the following: python3.10, python3.11, python3.12, python3.13, python3.14, nodejs22.x, or nodejs24.x."
  }
}

variable "source_kms_key_arn" {
  description = "Existing customer-managed KMS key ARN for Lambda ZIP code encryption; null uses AWS-owned encryption"
  type        = string
  default     = null

  validation {
    condition     = var.source_kms_key_arn == null ? true : can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/.+$", var.source_kms_key_arn))
    error_message = "source_kms_key_arn must be a KMS key ARN, not an alias."
  }
}

variable "kms_key_arn" {
  description = "Existing customer-managed KMS key ARN for environment variables and other Lambda-managed artifacts; null uses AWS-owned encryption"
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null ? true : can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/.+$", var.kms_key_arn))
    error_message = "kms_key_arn must be a KMS key ARN, not an alias."
  }
}

variable "permissions" {
  description = "Permissions that allow services or accounts to invoke the Lambda function"
  type = map(object({
    statement_id   = string
    principal      = string
    source_arn     = optional(string)
    source_account = optional(string)
  }))
  default = {}
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 3

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900 && floor(var.timeout) == var.timeout
    error_message = "timeout must be an integer between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Lambda memory allocation in MB"
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240 && floor(var.memory_size) == var.memory_size
    error_message = "memory_size must be an integer between 128 and 10240 MB."
  }
}

variable "layers" {
  description = "Ordered list of Lambda layer version ARNs compatible with the function runtime and architecture"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.layers) <= 5
    error_message = "A Lambda function supports at most five layers."
  }
}

variable "vpc_config" {
  description = "Optional VPC attachment; subnets and security groups must belong to vpc_id"
  type = object({
    vpc_id                = string
    subnet_ids            = set(string)
    security_group_ids    = optional(set(string), [])
    create_security_group = optional(bool, true)
  })
  default = null

  validation {
    condition = var.vpc_config == null ? true : (
      length(var.vpc_config.subnet_ids) > 0 &&
      (var.vpc_config.create_security_group || length(var.vpc_config.security_group_ids) > 0)
    )
    error_message = "VPC configuration requires subnets and either a managed security group or existing security_group_ids."
  }
}

variable "security_group_ingress_rules" {
  description = "Inbound rules for the managed security group; no inbound access is allowed by default"
  type = map(object({
    description = optional(string)
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_ipv4   = string
  }))
  default = {}

  validation {
    condition = alltrue([for rule in values(var.security_group_ingress_rules) :
      can(cidrnetmask(rule.cidr_ipv4))
    ])
    error_message = "Each ingress rule must specify a valid IPv4 CIDR in cidr_ipv4."
  }
}

variable "security_group_egress_rules" {
  description = "Outbound rules for the managed security group; no outbound access is allowed by default"
  type = map(object({
    description = optional(string)
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_ipv4   = string
  }))
  default = {}

  validation {
    condition = alltrue([for rule in values(var.security_group_egress_rules) :
      can(cidrnetmask(rule.cidr_ipv4))
    ])
    error_message = "Each egress rule must specify a valid IPv4 CIDR in cidr_ipv4."
  }
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days; 0 retains logs indefinitely"
  type        = number
  default     = 7
  nullable    = false

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_in_days)
    error_message = "log_retention_in_days must be a supported CloudWatch retention period: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, or 3653."
  }
}

variable "enable_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for Lambda errors, throttles, and duration"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "Action ARNs (for example SNS topics) notified when a Lambda alarm enters ALARM"
  type        = list(string)
  default     = []
}

variable "cloudwatch_alarms" {
  description = "Complete map of Lambda alarms; replaces the default map. A null Duration threshold uses 80% of timeout in milliseconds"
  type = map(object({
    metric_name               = string
    enabled                   = optional(bool, true)
    threshold                 = optional(number)
    statistic                 = optional(string)
    extended_statistic        = optional(string)
    comparison_operator       = optional(string, "GreaterThanOrEqualToThreshold")
    period                    = optional(number, 300)
    evaluation_periods        = optional(number, 1)
    datapoints_to_alarm       = optional(number)
    treat_missing_data        = optional(string, "notBreaching")
    alarm_actions             = optional(list(string))
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
  }))
  default = {
    errors = {
      metric_name = "Errors"
      threshold   = 1
      statistic   = "Sum"
    }
    throttles = {
      metric_name = "Throttles"
      threshold   = 1
      statistic   = "Sum"
    }
    duration = {
      metric_name        = "Duration"
      extended_statistic = "p95"
    }
  }

  validation {
    condition     = alltrue([for alarm in values(var.cloudwatch_alarms) : alarm.threshold != null || alarm.metric_name == "Duration"])
    error_message = "An explicit threshold is required for metrics other than Duration."
  }

  validation {
    condition = alltrue([for alarm in values(var.cloudwatch_alarms) :
      alarm.statistic == null || alarm.extended_statistic == null
    ])
    error_message = "Specify statistic or extended_statistic, not both, for each alarm."
  }
}

variable "dynamodb_stream_event_source_mappings" {
  description = "DynamoDB Stream event source mappings for the Lambda function"
  type = map(object({
    event_source_arn                   = string
    starting_position                  = string
    batch_size                         = optional(number)
    enabled                            = optional(bool, true)
    maximum_batching_window_in_seconds = optional(number)
    function_response_types            = optional(set(string))
    maximum_record_age_in_seconds      = optional(number)
    maximum_retry_attempts             = optional(number)
    parallelization_factor             = optional(number)
    bisect_batch_on_function_error     = optional(bool)
    tumbling_window_in_seconds         = optional(number)
  }))
  default = {}
}

variable "kinesis_stream_event_source_mappings" {
  description = "Kinesis Stream event source mappings for the Lambda function"
  type = map(object({
    event_source_arn                   = string
    starting_position                  = string
    batch_size                         = optional(number)
    enabled                            = optional(bool, true)
    starting_position_timestamp        = optional(string)
    maximum_batching_window_in_seconds = optional(number)
    function_response_types            = optional(set(string))
    maximum_record_age_in_seconds      = optional(number)
    maximum_retry_attempts             = optional(number)
    parallelization_factor             = optional(number)
    bisect_batch_on_function_error     = optional(bool)
    tumbling_window_in_seconds         = optional(number)
  }))
  default = {}
}

variable "sqs_queue_event_source_mappings" {
  description = "SQS Queue event source mappings, optionally filtered"
  type = map(object({
    event_source_arn                   = string
    batch_size                         = optional(number)
    enabled                            = optional(bool, true)
    maximum_batching_window_in_seconds = optional(number)
    function_response_types            = optional(set(string))
    maximum_concurrency                = optional(number)
    filters = optional(list(object({
      pattern = string
    })), [])
  }))
  default = {}
}

variable "amazon_msk_event_source_mappings" {
  description = "Amazon MSK event source mappings for the Lambda function"
  type = map(object({
    event_source_arn                   = string
    topics                             = set(string)
    batch_size                         = optional(number)
    enabled                            = optional(bool, true)
    maximum_batching_window_in_seconds = optional(number)
    function_response_types            = optional(set(string))
    maximum_record_age_in_seconds      = optional(number)
    maximum_retry_attempts             = optional(number)
    filters = optional(list(object({
      pattern = string
    })), [])
    consumer_group_id = optional(string)
    source_access_configuration = optional(list(object({
      type = string
      uri  = string
    })), [])
  }))
  default = {}
}

variable "extra_policies" {
  description = "Extra IAM policies to attach to the Lambda function"
  type        = map(string)
  default     = {}
}
