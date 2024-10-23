locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  cold_start_query_filter = local.query_filter == "{*}" ? "{cold_start:true}" : replace(local.query_filter, "{", "{cold_star:true,")
}

resource "datadog_monitor" "error_rate" {
  count = var.error_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Lambda error rate - {{functionname.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.error_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.error_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.error_rate_evaluation_window}):
      default(avg:aws.lambda.errors${local.query_filter} by {functionname,region,aws_account,env,datadog_managed}.as_rate(), 0) / (
      default(avg:aws.lambda.invocations${local.query_filter} by {functionname,region,aws_account,env,datadog_managed}.as_rate(), 1)
    ) * 100 > ${var.error_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.error_rate_threshold_critical
    warning  = var.error_rate_threshold_warning
  }
}

resource "datadog_monitor" "timeouts" {
  count = var.timeouts_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Lambda timeouts - {{functionname.name}}", local.title_suffix])
  include_tags = false
  message      = var.timeouts_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.timeouts_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.timeouts_evaluation_window}):
      default(avg:aws.lambda.duration.maximum${local.query_filter} by {functionname,region,aws_account,env,datadog_managed}.as_rate(), 0) / (
      (default(avg:aws.lambda.timeout${local.query_filter} by {functionname,region,aws_account,env,datadog_managed}.as_rate(), 1) * 1000)
    )  > ${var.timeouts_threshold_critical}
END

  monitor_thresholds {
    critical = var.timeouts_threshold_critical
    warning  = var.timeouts_threshold_warning
  }
}

resource "datadog_monitor" "cold_starts" {
  count = var.cold_starts_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Lambda cold starts - {{functionname.name}}", local.title_suffix])
  include_tags = false
  message      = var.cold_starts_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cold_starts_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.cold_starts_evaluation_window}):
      default(avg:aws.lambda.enhanced.invocations${local.cold_start_query_filter} by {functionname,region,aws_account,env,datadog_managed}.as_rate(), 0) / (
      default(avg:aws.lambda.enhanced.invocations${local.query_filter} by {functionname,region,aws_account,env,datadog_managed}.as_rate(), 1)
    ) > ${var.cold_starts_threshold_critical}
END

  monitor_thresholds {
    critical = var.cold_starts_threshold_critical
    warning  = var.cold_starts_threshold_warning
  }
}

resource "datadog_monitor" "out_of_memory" {
  count = var.out_of_memory_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Lambda out of memory - {{functionname.name}}", local.title_suffix])
  include_tags = false
  message      = var.out_of_memory_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.out_of_memory_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.out_of_memory_evaluation_window}):
      default(avg:aws.lambda.enhanced.invocations${local.query_filter} by {functionname,region,aws_account}.as_rate(), 0) / (
      default(avg:aws.lambda.enhanced.invocations${local.query_filter} by {functionname,region,aws_account}.as_rate(), 1)
    ) > ${var.out_of_memory_threshold_critical}
END

  monitor_thresholds {
    critical = var.out_of_memory_threshold_critical
    warning  = var.out_of_memory_threshold_warning
  }
}

resource "datadog_monitor" "iterator_age" {
  count = var.iterator_age_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Lambda iterator age - {{functionname.name}}", local.title_suffix])
  include_tags = false
  message      = var.iterator_age_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.iterator_age_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.iterator_age_evaluation_window}):
      default(avg:aws.lambda.iterator_age.maximum${local.query_filter} by {functionname,region,aws_account,env,datadog_managed}
    > ${var.iterator_age_threshold_critical}
END

  monitor_thresholds {
    critical = var.iterator_age_threshold_critical
    warning  = var.iterator_age_threshold_warning
  }
}

resource "datadog_monitor" "iterator_age_forecast" {
  count = var.iterator_age_forecast_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Lambda stream data loss forecasted - {{functionname.name}}", local.title_suffix])
  include_tags = false
  message      = var.iterator_age_forecast_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.iterator_age_forecast_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.iterator_age_forecast_evaluation_window}):
      forecast(max:aws.lambda.iterator_age.maximum${local.query_filter} by {functionname,region,aws_account}.as_count())
    >= 86400000
END

  monitor_thresholds {
    critical = 86400000
  }
}

resource "datadog_monitor" "throttle_rate" {
  count = var.throttle_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Lambda throttle rate - {{functionname.name}}", local.title_suffix])
  include_tags = false
  message      = var.throttle_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.throttle_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.throttle_rate_evaluation_window}):(
      default(avg:aws.lambda.throttles${local.query_filter} by {functionname,region,aws_account}.as_rate(), 0) / (
        default(avg:aws.lambda.throttles${local.query_filter} by {functionname,region,aws_account}.as_rate(), 0) +
        default(avg:aws.lambda.invocations${local.query_filter} by {functionname,region,aws_account}.as_rate(), 1)
      )
    ) * 100 > ${var.throttle_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.throttle_rate_threshold_critical
    warning  = var.throttle_rate_threshold_warning
  }
}
