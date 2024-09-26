# Service check
locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "running_tasks" {
  count = var.running_tasks_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS service failed tasks - {{servicename.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.running_tasks_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.running_tasks_evaluation_window}):(
      avg:aws.ecs.service.running${local.query_filter} by {servicename,region,aws_account,env} /
      avg:aws.ecs.service.desired${local.query_filter} by {servicename,region,aws_account,env}
    ) <= ${var.running_tasks_threshold_critical}
END

  monitor_thresholds {
    critical = var.running_tasks_threshold_critical
    warning  = var.running_tasks_threshold_warning
  }
}

resource "datadog_monitor" "cpu_utilization" {
  count = var.cpu_utilization_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS Service CPU Utilization - {{servicename.name}} - {{value}}%", local.title_suffix])
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
      avg:aws.ecs.cpuutilization${local.query_filter} by {servicename,region,aws_account,env}
    >= ${var.cpu_utilization_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_threshold_critical
    warning  = var.cpu_utilization_threshold_warning
  }
}

resource "datadog_monitor" "cpu_utilization_anomaly" {
  count = var.cpu_utilization_anomaly_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS service CPU utilization anomalous activity - {{servicename.name}}", local.title_suffix])
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
      avg:aws.ecs.cpuutilization${local.query_filter} by {servicename,region,aws_account,env}, 'agile', ${var.cpu_utilization_anomaly_deviations},
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

resource "datadog_monitor" "memory_utilization" {
  count = var.memory_utilization_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ECS Service memory utilization - {{servicename.name}} - {{value}}%", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.memory_utilization_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.memory_utilization_evaluation_window}):
      avg:aws.ecs.memory_utilization${local.query_filter} by {servicename,region,aws_account,env}
    >= ${var.memory_utilization_threshold_critical}
END

  monitor_thresholds {
    critical = var.memory_utilization_threshold_critical
    warning  = var.memory_utilization_threshold_warning
  }
}
