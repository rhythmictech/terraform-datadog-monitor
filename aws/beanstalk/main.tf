locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  latency_metric_map = {
    "p10"  = "application_latency_p_1_0"
    "p50"  = "application_latency_p_5_0"
    "p75"  = "application_latency_p_7_0"
    "p85"  = "application_latency_p_8_0"
    "p90"  = "application_latency_p_9_0"
    "p95"  = "application_latency_p_9_5"
    "p99"  = "application_latency_p_9_9"
    "p999" = "application_latency_p_9_9"
  }

  latency_metric = local.latency_metric_map[var.latency_measurement]

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "health" {
  count = var.health_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Beanstalk Health Events - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "metric alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.health_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.health_evaluation_window}):
      min:aws.elasticbeanstalk.environment_health${local.query_filter} by {environmentname,region,aws_account}
    >= ${var.health_threshold_critical}
END

  monitor_thresholds {
    critical = var.health_threshold_critical
    warning  = var.health_threshold_warning
  }
}

resource "datadog_monitor" "http_5xx_responses" {
  count = var.http_5xx_responses_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ALB 5xx Responses - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.http_5xx_responses_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.http_5xx_responses_evaluation_window}):(
      default(sum:aws.elasticbeanstalk.application_requests_5xx${local.query_filter} by {environmentname,region,aws_account}.as_rate(), 0) /
      default(sum:aws.elasticbeanstalk.application_requests_total${local.query_filter} by {environmentname,region,aws_account}.as_rate(), 1)
    ) * 100 > ${var.http_5xx_responses_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_5xx_responses_threshold_critical
    warning  = var.http_5xx_responses_threshold_warning
  }
}

resource "datadog_monitor" "latency" {
  count = var.latency_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Beanstalk Latency - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.health_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min:${var.latency_evaluation_window}):min:aws.elasticbeanstalk.${local.latency_metric}${local.query_filter} by {environmentname,region,aws_account}
     >= ${var.latency_threshold_critical}
END

  monitor_thresholds {
    critical = var.latency_threshold_critical
    warning  = var.latency_threshold_warning
  }
}

resource "datadog_monitor" "root_disk_usage" {
  count = var.root_disk_usage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Beanstalk Instance Root Disk Usage - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.root_disk_usage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max:${var.latency_evaluation_window}):
      min:aws.elasticbeanstalk.root_filesystem_util${local.query_filter} by {host,environmentname,region,aws_account}
    >= ${var.root_disk_usage_threshold_critical}
END

  monitor_thresholds {
    critical = var.root_disk_usage_threshold_critical
    warning  = var.root_disk_usage_threshold_warning
  }
}
