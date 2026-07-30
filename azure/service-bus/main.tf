locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  # `entity_name` splits namespace-level metrics down to the individual queue or
  # topic when the dimension is present.
  group_by = "name,entity_name,subscription_name,resource_group,region,env,datadog_managed"
}

resource "datadog_monitor" "dead_lettered_messages" {
  count = var.dead_lettered_messages_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Service Bus dead-lettered messages - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.dead_lettered_messages_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.dead_lettered_messages_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.dead_lettered_messages_evaluation_window}):
      max:azure.servicebus_namespaces.count_of_dead_lettered_messages_in_a_queue_topic${local.query_filter} by {${local.group_by}}
    > ${var.dead_lettered_messages_threshold_critical}
END

  monitor_thresholds {
    critical = var.dead_lettered_messages_threshold_critical
    warning  = var.dead_lettered_messages_threshold_warning
  }
}

resource "datadog_monitor" "server_errors" {
  count = var.server_errors_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Service Bus server errors - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.server_errors_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.server_errors_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.server_errors_evaluation_window}):
      default(sum:azure.servicebus_namespaces.server_errors${local.query_filter} by {${local.group_by}}.as_count(), 0)
    > ${var.server_errors_threshold_critical}
END

  monitor_thresholds {
    critical = var.server_errors_threshold_critical
  }
}

resource "datadog_monitor" "throttled_requests" {
  count = var.throttled_requests_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Service Bus throttled requests - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.throttled_requests_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.throttled_requests_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.throttled_requests_evaluation_window}):
      default(sum:azure.servicebus_namespaces.throttled_requests${local.query_filter} by {${local.group_by}}.as_count(), 0)
    > ${var.throttled_requests_threshold_critical}
END

  monitor_thresholds {
    critical = var.throttled_requests_threshold_critical
    warning  = var.throttled_requests_threshold_warning
  }
}

# Thresholds are workload-specific; the defaults are deliberately generous so
# the monitor is useful out of the box without paging on normal burst traffic.
resource "datadog_monitor" "active_messages_backlog" {
  count = var.active_messages_backlog_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Service Bus message backlog - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.active_messages_backlog_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.active_messages_backlog_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.active_messages_backlog_evaluation_window}):
      max:azure.servicebus_namespaces.count_of_active_messages_in_a_queue_topic${local.query_filter} by {${local.group_by}}
    > ${var.active_messages_backlog_threshold_critical}
END

  monitor_thresholds {
    critical = var.active_messages_backlog_threshold_critical
    warning  = var.active_messages_backlog_threshold_warning
  }
}

# Disabled by default: user errors are usually application-side (bad payloads,
# expired locks) and are noisy as an infrastructure alert.
resource "datadog_monitor" "user_errors" {
  count = var.user_errors_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Service Bus user errors - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.user_errors_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.user_errors_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.user_errors_evaluation_window}):
      default(sum:azure.servicebus_namespaces.user_errors${local.query_filter} by {${local.group_by}}.as_count(), 0)
    > ${var.user_errors_threshold_critical}
END

  monitor_thresholds {
    critical = var.user_errors_threshold_critical
    warning  = var.user_errors_threshold_warning
  }
}

# Disabled by default: emitted only by Premium SKU namespaces.
resource "datadog_monitor" "cpu" {
  count = var.cpu_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Service Bus CPU high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.cpu_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cpu_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.cpu_evaluation_window}):
      avg:azure.servicebus_namespaces.cpu${local.query_filter} by {${local.group_by}}
    > ${var.cpu_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_threshold_critical
    warning  = var.cpu_threshold_warning
  }
}

# Disabled by default: emitted only by Premium SKU namespaces.
resource "datadog_monitor" "memory_usage" {
  count = var.memory_usage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Service Bus memory high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.memory_usage_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.memory_usage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.memory_usage_evaluation_window}):
      avg:azure.servicebus_namespaces.memory_usage${local.query_filter} by {${local.group_by}}
    > ${var.memory_usage_threshold_critical}
END

  monitor_thresholds {
    critical = var.memory_usage_threshold_critical
    warning  = var.memory_usage_threshold_warning
  }
}
