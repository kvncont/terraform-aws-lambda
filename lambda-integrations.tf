resource "aws_lambda_permission" "this" {
  for_each = var.permissions

  statement_id   = each.value.statement_id
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.this.function_name
  principal      = each.value.principal
  source_arn     = each.value.source_arn
  source_account = each.value.source_account
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  for_each = var.dynamodb_stream_event_source_mappings
  tags     = var.tags

  event_source_arn                   = each.value.event_source_arn
  function_name                      = aws_lambda_function.this.arn
  starting_position                  = each.value.starting_position
  batch_size                         = each.value.batch_size
  enabled                            = each.value.enabled
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  function_response_types            = each.value.function_response_types
  maximum_record_age_in_seconds      = each.value.maximum_record_age_in_seconds
  maximum_retry_attempts             = each.value.maximum_retry_attempts
  parallelization_factor             = each.value.parallelization_factor
  bisect_batch_on_function_error     = each.value.bisect_batch_on_function_error
  tumbling_window_in_seconds         = each.value.tumbling_window_in_seconds
}

resource "aws_lambda_event_source_mapping" "kinesis_stream" {
  for_each = var.kinesis_stream_event_source_mappings
  tags     = var.tags

  event_source_arn                   = each.value.event_source_arn
  function_name                      = aws_lambda_function.this.arn
  starting_position                  = each.value.starting_position
  starting_position_timestamp        = each.value.starting_position_timestamp
  batch_size                         = each.value.batch_size
  enabled                            = each.value.enabled
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  function_response_types            = each.value.function_response_types
  maximum_record_age_in_seconds      = each.value.maximum_record_age_in_seconds
  maximum_retry_attempts             = each.value.maximum_retry_attempts
  parallelization_factor             = each.value.parallelization_factor
  bisect_batch_on_function_error     = each.value.bisect_batch_on_function_error
  tumbling_window_in_seconds         = each.value.tumbling_window_in_seconds
}

resource "aws_lambda_event_source_mapping" "sqs_queue" {
  for_each = var.sqs_queue_event_source_mappings
  tags     = var.tags

  event_source_arn                   = each.value.event_source_arn
  function_name                      = aws_lambda_function.this.arn
  batch_size                         = each.value.batch_size
  enabled                            = each.value.enabled
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  function_response_types            = each.value.function_response_types

  dynamic "filter_criteria" {
    for_each = length(each.value.filters) > 0 ? [each.value.filters] : []

    content {
      dynamic "filter" {
        for_each = filter_criteria.value

        content {
          pattern = filter.value.pattern
        }
      }
    }

  }

  dynamic "scaling_config" {
    for_each = each.value.maximum_concurrency == null ? [] : [each.value.maximum_concurrency]

    content {
      maximum_concurrency = scaling_config.value
    }
  }
}

resource "aws_lambda_event_source_mapping" "amazon_msk" {
  for_each = var.amazon_msk_event_source_mappings
  tags     = var.tags

  event_source_arn                   = each.value.event_source_arn
  function_name                      = aws_lambda_function.this.arn
  topics                             = each.value.topics
  batch_size                         = each.value.batch_size
  enabled                            = each.value.enabled
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  function_response_types            = each.value.function_response_types
  maximum_record_age_in_seconds      = each.value.maximum_record_age_in_seconds
  maximum_retry_attempts             = each.value.maximum_retry_attempts

  dynamic "filter_criteria" {
    for_each = length(each.value.filters) > 0 ? [each.value.filters] : []

    content {
      dynamic "filter" {
        for_each = filter_criteria.value

        content {
          pattern = filter.value.pattern
        }
      }
    }
  }

  dynamic "amazon_managed_kafka_event_source_config" {
    for_each = each.value.consumer_group_id == null ? [] : [each.value.consumer_group_id]

    content {
      consumer_group_id = amazon_managed_kafka_event_source_config.value
    }
  }

  dynamic "source_access_configuration" {
    for_each = each.value.source_access_configuration

    content {
      type = source_access_configuration.value.type
      uri  = source_access_configuration.value.uri
    }
  }
}
