resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda" {
  for_each = { for name, alarm in var.cloudwatch_alarms : name => alarm if var.enable_cloudwatch_alarms && alarm.enabled }

  alarm_name                = "cloudwatch-alarm-lambda-${var.function_name}-${each.key}"
  alarm_description         = "Lambda ${each.value.metric_name}: ${each.value.comparison_operator}, period ${each.value.period}s"
  namespace                 = "AWS/Lambda"
  metric_name               = each.value.metric_name
  comparison_operator       = each.value.comparison_operator
  threshold                 = each.value.threshold == null ? var.timeout * 1000 * 0.8 : each.value.threshold
  statistic                 = each.value.extended_statistic == null ? coalesce(each.value.statistic, "Sum") : null
  extended_statistic        = each.value.extended_statistic
  period                    = each.value.period
  evaluation_periods        = each.value.evaluation_periods
  datapoints_to_alarm       = each.value.datapoints_to_alarm
  treat_missing_data        = each.value.treat_missing_data
  alarm_actions             = each.value.alarm_actions == null ? var.alarm_actions : each.value.alarm_actions
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions
  tags                      = var.tags

  lifecycle {
    precondition {
      condition = each.value.datapoints_to_alarm == null ? true : (
        each.value.datapoints_to_alarm >= 1 &&
        each.value.datapoints_to_alarm <= each.value.evaluation_periods &&
        floor(each.value.datapoints_to_alarm) == each.value.datapoints_to_alarm
      )
      error_message = "datapoints_to_alarm must be a positive integer no greater than evaluation_periods."
    }
  }

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }
}