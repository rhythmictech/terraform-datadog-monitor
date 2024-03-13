locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "cpu_utilization" {
  count = var.cpu_utilization_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Elasticache CPU Utilization - {{host.name}}", local.title_suffix])
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
      avg:aws.elasticache.cpuutilization${local.query_filter} by {cachenodeid,cacheclusterid,region,aws_account}
    >= ${var.cpu_utilization_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_threshold_critical
    warning  = var.cpu_utilization_threshold_warning
  }
}

resource "datadog_monitor" "cpu_utilization_anomaly" {
  count = var.cpu_utilization_anomaly_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Elasticache CPU utilization anomalous activity - {{host.name}}", local.title_suffix])
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
    avg(${var.cpu_utilization_evaluation_window}):anomalies(
      avg:aws.elasticache.cpuutilization${local.query_filter} by {cachenodeid,cacheclusterid,region,aws_account}, 'agile', ${var.cpu_utilization_anomaly_deviations},
      direction='above', count_default_zero='true', interval=${var.cpu_utilization_anomaly_rollup},
      seasonality='${var.cpu_utilization_anomaly_seasonality}'
    ) >= ${var.cpu_utilization_anomaly_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_anomaly_threshold_critical
  }
}

resource "datadog_monitor" "evictions" {
  count = var.evictions_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Elasticache evictions - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.evictions_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.evictions_evaluation_window}): (
      avg:aws.elasticache.evictions${local.query_filter} by {cachenodeid,cacheclusterid,region,aws_account}
    ) >= ${var.evictions_threshold_critical}
END

  monitor_thresholds {
    critical = var.evictions_threshold_critical
    warning  = var.evictions_threshold_warning
  }
}

resource "datadog_monitor" "hit_rate" {
  count = var.hit_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Elasticache cache hit rate - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.hit_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.hit_rate_evaluation_window}):(
      avg:aws.elasticache.cache_hit_rate${local.query_filter} by {cachenodeid,cacheclusterid,region,aws_account}
    )  >= ${var.hit_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.hit_rate_threshold_critical
    warning  = var.hit_rate_threshold_warning
  }
}

resource "datadog_monitor" "hit_rate_anomaly" {
  count = var.hit_rate_anomaly_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Elasticache cache hit rate anomalous activity - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.hit_rate_anomaly_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.hit_rate_evaluation_window}):anomalies(
      avg:aws.elasticache.cache_hit_rate${local.query_filter} by {cachenodeid,cacheclusterid,region,aws_account}, 'agile', ${var.hit_rate_anomaly_deviations},
      direction='below', count_default_zero='true',
      seasonality='${var.hit_rate_anomaly_seasonality}'
    ) >= ${var.hit_rate_anomaly_threshold_critical}
END

  monitor_thresholds {
    critical = var.hit_rate_anomaly_threshold_critical
  }
}

resource "datadog_monitor" "max_connections" {
  count = var.max_connections_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Elasticache max connections - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.max_connections_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.max_connections_evaluation_window}):(
      avg:aws.elasticache.curr_connections${local.query_filter} by {cachenodeid,cacheclusterid,region,aws_account}
    )  >= ${var.max_connections_threshold_critical}
END

  monitor_thresholds {
    critical = var.max_connections_threshold_critical
    warning  = var.max_connections_threshold_warning
  }
}

resource "datadog_monitor" "swap_usage" {
  count = var.swap_usage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Elasticache swap usage - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.swap_usage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.swap_usage_evaluation_window}):(
      avg:aws.elasticache.swap_usage${local.query_filter} by {cachenodeid,cacheclusterid,region,aws_account}
    )  <= ${var.swap_usage_threshold_critical}
END

  monitor_thresholds {
    critical = var.swap_usage_threshold_critical
    warning  = var.swap_usage_threshold_warning
  }
}
