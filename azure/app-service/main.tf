locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  group_by = "name,subscription_name,resource_group,region,env,datadog_managed"
}

resource "datadog_monitor" "http_5xx_rate" {
  count = var.http_5xx_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service 5xx rate - {{name.name}} - {{value}}%", local.title_suffix])
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
      default(avg:azure.app_services.http5xx${local.query_filter} by {${local.group_by}}.as_rate(), 0) / (
      default(avg:azure.app_services.requests${local.query_filter} by {${local.group_by}}.as_rate(), 1)
    ) * 100 > ${var.http_5xx_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_5xx_rate_threshold_critical
    warning  = var.http_5xx_rate_threshold_warning
  }
}

resource "datadog_monitor" "response_time" {
  count = var.response_time_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service response time - {{name.name}} - {{value}}s", local.title_suffix])
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
      avg:azure.app_services.average_response_time${local.query_filter} by {${local.group_by}}
    > ${var.response_time_threshold_critical}
END

  monitor_thresholds {
    critical = var.response_time_threshold_critical
    warning  = var.response_time_threshold_warning
  }
}

# Disabled by default: 4xx on a public web app is largely client-driven and
# alerts on scanner traffic more often than on real faults.
resource "datadog_monitor" "http_4xx_rate" {
  count = var.http_4xx_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service 4xx rate - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.http_4xx_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.http_4xx_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.http_4xx_rate_evaluation_window}):
      default(avg:azure.app_services.http4xx${local.query_filter} by {${local.group_by}}.as_rate(), 0) / (
      default(avg:azure.app_services.requests${local.query_filter} by {${local.group_by}}.as_rate(), 1)
    ) * 100 > ${var.http_4xx_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_4xx_rate_threshold_critical
    warning  = var.http_4xx_rate_threshold_warning
  }
}

# Disabled by default: only emits once a health-check path is configured on the
# app, so enabling it blind produces a no-data monitor.
resource "datadog_monitor" "health_check_status" {
  count = var.health_check_status_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service health check - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.app_services.health_check_status${local.query_filter} by {${local.group_by}}
    < ${var.health_check_status_threshold_critical}
END

  monitor_thresholds {
    critical = var.health_check_status_threshold_critical
    warning  = var.health_check_status_threshold_warning
  }
}

# Disabled by default: Datadog documents the unit as `byte` while the metric
# description says "percentage of filesystem quota consumed". Confirm against
# live data before enabling and setting a threshold.
resource "datadog_monitor" "file_system_usage" {
  count = var.file_system_usage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service filesystem quota - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.file_system_usage_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.file_system_usage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.file_system_usage_evaluation_window}):
      avg:azure.app_services.file_system_usage${local.query_filter} by {${local.group_by}}
    > ${var.file_system_usage_threshold_critical}
END

  monitor_thresholds {
    critical = var.file_system_usage_threshold_critical
    warning  = var.file_system_usage_threshold_warning
  }
}
