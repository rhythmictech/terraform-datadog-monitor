locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "oldest_message" {
  count = var.oldest_message_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Oldest queued message - {{queuename.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.oldest_message_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.oldest_message_evaluation_window}):(
      avg:aws.sqs.approximate_age_of_oldest_message${local.query_filter} by {queuename,region,env,datadog_critical}
    ) > ${var.oldest_message_threshold_critical}
END

  monitor_thresholds {
    critical = var.oldest_message_threshold_critical
    warning  = var.oldest_message_threshold_warning
  }
}

resource "datadog_monitor" "queue_depth" {
  count = var.queue_depth_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Queue depth - {{queuename.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.queue_depth_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.queue_depth_evaluation_window}):(
      avg:aws.sqs.approximate_number_of_messages_visible${local.query_filter} by {queuename,region,env,datadog_critical}
    ) > ${var.queue_depth_threshold_critical}
END

  monitor_thresholds {
    critical = var.queue_depth_threshold_critical
    warning  = var.queue_depth_threshold_warning
  }
}
