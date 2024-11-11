locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "disk_space" {
  count = var.disk_space_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Disk Space - {{name.name}}", local.title_suffix])
  message      = var.disk_space_use_message ? local.query_alert_base_message : ""
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)
  type    = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  notify_audit        = false
  timeout_h           = var.timeout_h
  include_tags        = true
  require_full_window = true

  query = <<EOQ
    ${var.disk_space_time_aggregator}(${var.disk_space_timeframe}):
      avg:system.disk.in_use${local.query_filter} by {name,aws_account,device,env,datadog_managed}
    * 100 > ${var.disk_space_threshold_critical}
  EOQ

  monitor_thresholds {
    warning  = var.disk_space_threshold_warning
    critical = var.disk_space_threshold_critical
  }
}

resource "datadog_monitor" "disk_space_forecast" {
  count = var.disk_space_forecast_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Disk Space Forecast - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.disk_space_forecast_use_message ? local.query_alert_base_message : ""
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)
  type    = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_audit        = false
  timeout_h           = var.timeout_h
  require_full_window = true
  notify_no_data      = false
  renotify_interval   = 0

  query = <<EOQ
    ${var.disk_space_forecast_time_aggregator}(${var.disk_space_forecast_timeframe}):
      forecast(avg:system.disk.in_use${local.query_filter} by {name,aws_account,device,env,datadog_managed} * 100,
              '${var.disk_space_forecast_algorithm}',
               ${var.disk_space_forecast_deviations},
               interval='${var.disk_space_forecast_interval}',
               ${var.disk_space_forecast_algorithm == "linear" ? format("history='%s',model='%s'", var.disk_space_forecast_linear_history, var.disk_space_forecast_linear_model) : ""}
               ${var.disk_space_forecast_algorithm == "seasonal" ? format("seasonality='%s'", var.disk_space_forecast_seasonal_seasonality) : ""}
              )
    >= ${var.disk_space_forecast_threshold_critical}
  EOQ

  monitor_thresholds {
    critical_recovery = var.disk_space_forecast_threshold_critical_recovery
    critical          = var.disk_space_forecast_threshold_critical
  }
}

resource "datadog_monitor" "disk_inodes" {
  count = var.disk_inodes_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Disk Inodes Usage - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.disk_inodes_use_message ? local.query_alert_base_message : ""
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)
  type    = "query alert"

  query = <<EOQ
    ${var.disk_inodes_time_aggregator}(${var.disk_inodes_timeframe}):
      avg:system.fs.inodes.in_use${local.query_filter} by {name,aws_account,device,env,datadog_managed}
    * 100 > ${var.disk_inodes_threshold_critical}
  EOQ

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  notify_audit        = false
  timeout_h           = var.timeout_h
  require_full_window = true

  monitor_thresholds {
    warning  = var.disk_inodes_threshold_warning
    critical = var.disk_inodes_threshold_critical
  }
}
