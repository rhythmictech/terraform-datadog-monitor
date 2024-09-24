locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "connection_count_anomaly" {
  count = var.connection_count_anomaly_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "RDS connection count anomalous activity - {{dbinstanceidentifier.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.connection_count_anomaly_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.connection_count_anomaly_evaluation_window}):anomalies(
      avg:aws.rds.database_connections${local.query_filter} by {dbinstanceidentifier,region,aws_account,env}, 'agile', ${var.connection_count_anomaly_deviations},
      direction='both', count_default_zero='true', interval=${var.connection_count_anomaly_rollup},
      seasonality='${var.connection_count_anomaly_seasonality}'
    ) >= ${var.connection_count_anomaly_threshold_critical}
END

  monitor_thresholds {
    critical = var.connection_count_anomaly_threshold_critical
    warning  = var.connection_count_anomaly_threshold_warning
  }

  monitor_threshold_windows {
    recovery_window = var.connection_count_anomaly_recovery_window
    trigger_window  = var.connection_count_anomaly_trigger_window
  }
}

resource "datadog_monitor" "cpu_utilization" {
  count = var.cpu_utilization_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "RDS CPU Utilization - {{dbinstanceidentifier.name}} - {{value}}%", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cpu_utilization_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.cpu_utilization_evaluation_window}):
      avg:aws.rds.cpuutilization${local.query_filter} by {dbinstanceidentifier,region,aws_account,env}
    >= ${var.cpu_utilization_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_threshold_critical
    warning  = var.cpu_utilization_threshold_warning
  }
}

resource "datadog_monitor" "cpu_utilization_anomaly" {
  count = var.cpu_utilization_anomaly_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "RDS CPU utilization anomalous activity - {{dbinstanceidentifier.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cpu_utilization_anomaly_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.cpu_utilization_anomaly_evaluation_window}):anomalies(
      avg:aws.rds.cpuutilization${local.query_filter} by {dbinstanceidentifier,region,aws_account,env}, 'agile', ${var.cpu_utilization_anomaly_deviations},
      direction='below', count_default_zero='true', interval=${var.cpu_utilization_anomaly_rollup},
      seasonality='${var.cpu_utilization_anomaly_seasonality}'
    ) >= ${var.cpu_utilization_anomaly_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_anomaly_threshold_critical
    warning  = var.cpu_utilization_anomaly_threshold_warning
  }

  monitor_threshold_windows {
    recovery_window = var.cpu_utilization_anomaly_recovery_window
    trigger_window  = var.cpu_utilization_anomaly_trigger_window
  }
}

resource "datadog_monitor" "used_storage" {
  count = var.used_storage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "RDS instance storage - {{dbinstanceidentifier.name}} - {{value}}% used", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.used_storage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.used_storage_evaluation_window}):(
      100 - ((
        default(avg:aws.rds.free_storage_space${local.query_filter} by {dbinstanceidentifier,region,aws_account,env}, 0) /
        default(avg:aws.rds.total_storage_space${local.query_filter} by {dbinstanceidentifier,region,aws_account,env}, 1)
      ) * 100)
    ) >= ${var.used_storage_threshold_critical}
END

  monitor_thresholds {
    critical = var.used_storage_threshold_critical
    warning  = var.used_storage_threshold_warning
  }
}
