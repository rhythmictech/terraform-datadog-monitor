# Monitors related to ECS Cluster
locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "agent_status" {
  count = var.agent_status_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS Agent disconnected - {{clustername.name}}", local.title_suffix])
  include_tags = false
  message      = var.agent_status_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "service check"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.agent_status_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<EOQ
    "aws.ecs.agent_connected"${local.service_filter}.by("clustername","instance_id",env,datadog_managed).last(6).count_by_status()
EOQ

  monitor_thresholds {
    critical = var.agent_status_threshold_critical
    warning  = var.agent_status_threshold_warning
  }
}

resource "datadog_monitor" "cpu_utilization" {
  count = var.cpu_utilization_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS Cluster CPU Utilization - {{clustername.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.cpu_utilization_use_message ? local.query_alert_base_message : ""
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
    min(${var.cpu_utilization_evaluation_window}):
      avg:aws.ecs.cluster.cpuutilization${local.query_filter} by {clustername,region,aws_account,env,datadog_managed}
    > ${var.cpu_utilization_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_threshold_critical
    warning  = var.cpu_utilization_threshold_warning
  }
}

resource "datadog_monitor" "cpu_utilization_anomaly" {
  count = var.cpu_utilization_anomaly_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS cluster CPU utilization anomalous activity - {{clustername.name}}", local.title_suffix])
  include_tags = false
  message      = var.cpu_utilization_anomaly_use_message ? local.query_alert_base_message : ""
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
      avg:aws.ecs.cluster.cpuutilization${local.query_filter} by {clustername,region,aws_account,env,datadog_managed}, 'agile', ${var.cpu_utilization_anomaly_deviations},
      direction='above', count_default_zero='true', interval=${var.cpu_utilization_anomaly_rollup},
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

resource "datadog_monitor" "memory_reservation" {
  count = var.memory_reservation_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS Cluster Memory Reservation High - {{clustername.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.memory_reservation_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.memory_reservation_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.memory_reservation_evaluation_window}):
      avg:aws.ecs.cluster.memory_reservation${local.query_filter} by {clustername,region,aws_account,env,datadog_managed}
    > ${var.memory_reservation_threshold_critical}
END

  monitor_thresholds {
    critical = var.memory_reservation_threshold_critical
    warning  = var.memory_reservation_threshold_warning
  }
}
