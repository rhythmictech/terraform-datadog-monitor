locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "cluster_health_red" {
  count = var.cluster_health_red_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ElasticSearch cluster health red - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cluster_health_red_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.cluster_health_red_evaluation_window}):
      max:aws.es.cluster_statusred${local.query_filter} by {region,name}
    >= 1
END

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "cluster_health_yellow" {
  count = var.cluster_health_yellow_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ElasticSearch cluster health yellow - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cluster_health_yellow_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.cluster_health_yellow_evaluation_window}):
      max:aws.es.cluster_statusyellow${local.query_filter} by {region,name}
    >= 1
END

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "cpu_utilization" {
  count = var.cpu_utilization_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ElasticSearch CPU Utilization - {{host.name}}", local.title_suffix])
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
      avg:aws.es.cpuutilization${local.query_filter} by {region,name}
    >= ${var.cpu_utilization_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_threshold_critical
    warning  = var.cpu_utilization_threshold_warning
  }
}

resource "datadog_monitor" "cpu_utilization_anomaly" {
  count = var.cpu_utilization_anomaly_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ElasticSearch CPU utilization anomalous activity - {{host.name}}", local.title_suffix])
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
      avg:aws.es.cpuutilization${local.query_filter} by {region,name}, 'agile', ${var.cpu_utilization_anomaly_deviations},
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

resource "datadog_monitor" "free_storage" {
  count = var.free_storage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ElasticSearch cluster free storage - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.free_storage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.free_storage_evaluation_window}):(
        avg:aws.es.free_storage_storage${local.query_filter} by {region,name}
    ) < ${var.free_storage_threshold_critical}
    >= 1
END

  monitor_thresholds {
    critical = var.free_storage_threshold_critical
    warning  = var.free_storage_threshold_warning
  }
}
