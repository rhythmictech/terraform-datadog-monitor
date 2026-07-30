locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  group_by = "name,subscription_name,resource_group,region,env,datadog_managed"
}

# `azure.functions.*` has no `errors` metric; http5xx is the server-fault signal.
resource "datadog_monitor" "http_5xx_rate" {
  count = var.http_5xx_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Function App 5xx rate - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.http_5xx_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.http_5xx_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.http_5xx_rate_evaluation_window}):
      default(avg:azure.functions.http5xx${local.query_filter} by {${local.group_by}}.as_rate(), 0) / (
      default(avg:azure.functions.requests${local.query_filter} by {${local.group_by}}.as_rate(), 1)
    ) * 100 > ${var.http_5xx_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_5xx_rate_threshold_critical
    warning  = var.http_5xx_rate_threshold_warning
  }
}

# `azure.functions.*` has no `duration` metric; average_response_time is the
# closest equivalent.
resource "datadog_monitor" "response_time" {
  count = var.response_time_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Function App response time - {{name.name}} - {{value}}s", local.title_suffix])
  include_tags = false
  message      = var.response_time_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.response_time_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.response_time_evaluation_window}):
      avg:azure.functions.average_response_time${local.query_filter} by {${local.group_by}}
    > ${var.response_time_threshold_critical}
END

  monitor_thresholds {
    critical = var.response_time_threshold_critical
    warning  = var.response_time_threshold_warning
  }
}

# Disabled by default: an idle function app is legitimate for event-driven
# workloads. Enable per function app that is expected to run continuously.
resource "datadog_monitor" "execution_stall" {
  count = var.execution_stall_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Function App not executing - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.execution_stall_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.execution_stall_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.execution_stall_evaluation_window}):
      default(sum:azure.functions.function_execution_count${local.query_filter} by {${local.group_by}}.as_count(), 0)
    < 1
END

  monitor_thresholds {
    critical = 1
  }
}

# Disabled by default: the meaningful threshold depends on the hosting plan
# (Consumption caps at 1.5 GiB; Premium and Dedicated differ).
resource "datadog_monitor" "memory_working_set" {
  count = var.memory_working_set_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Function App memory working set high - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.memory_working_set_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.memory_working_set_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.memory_working_set_evaluation_window}):
      avg:azure.functions.average_memory_working_set${local.query_filter} by {${local.group_by}}
    > ${var.memory_working_set_threshold_critical}
END

  monitor_thresholds {
    critical = var.memory_working_set_threshold_critical
    warning  = var.memory_working_set_threshold_warning
  }
}

# Disabled by default: only emits once a health-check path is configured.
resource "datadog_monitor" "health_check_status" {
  count = var.health_check_status_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Function App health check - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.health_check_status_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.health_check_status_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.health_check_status_evaluation_window}):
      avg:azure.functions.health_check_status${local.query_filter} by {${local.group_by}}
    < ${var.health_check_status_threshold_critical}
END

  monitor_thresholds {
    critical = var.health_check_status_threshold_critical
    warning  = var.health_check_status_threshold_warning
  }
}
