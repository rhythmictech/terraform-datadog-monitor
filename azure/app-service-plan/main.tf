locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  group_by = "name,subscription_name,resource_group,region,env,datadog_managed"
}

resource "datadog_monitor" "cpu_percentage" {
  count = var.cpu_percentage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service Plan CPU high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.cpu_percentage_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cpu_percentage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.cpu_percentage_evaluation_window}):
      avg:azure.web_serverfarms.cpu_percentage${local.query_filter} by {${local.group_by}}
    > ${var.cpu_percentage_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_percentage_threshold_critical
    warning  = var.cpu_percentage_threshold_warning
  }
}

resource "datadog_monitor" "memory_percentage" {
  count = var.memory_percentage_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service Plan memory high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.memory_percentage_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.memory_percentage_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.memory_percentage_evaluation_window}):
      avg:azure.web_serverfarms.memory_percentage${local.query_filter} by {${local.group_by}}
    > ${var.memory_percentage_threshold_critical}
END

  monitor_thresholds {
    critical = var.memory_percentage_threshold_critical
    warning  = var.memory_percentage_threshold_warning
  }
}

resource "datadog_monitor" "http_queue_length" {
  count = var.http_queue_length_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service Plan HTTP queue backing up - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.http_queue_length_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.http_queue_length_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.http_queue_length_evaluation_window}):
      avg:azure.web_serverfarms.http_queue_length${local.query_filter} by {${local.group_by}}
    > ${var.http_queue_length_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_queue_length_threshold_critical
    warning  = var.http_queue_length_threshold_warning
  }
}

# Disabled by default: disk queueing is only meaningful on plans backed by
# storage-heavy workloads, and idles at zero elsewhere.
resource "datadog_monitor" "disk_queue_length" {
  count = var.disk_queue_length_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "App Service Plan disk queue backing up - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.disk_queue_length_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.disk_queue_length_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.disk_queue_length_evaluation_window}):
      avg:azure.web_serverfarms.disk_queue_length${local.query_filter} by {${local.group_by}}
    > ${var.disk_queue_length_threshold_critical}
END

  monitor_thresholds {
    critical = var.disk_queue_length_threshold_critical
    warning  = var.disk_queue_length_threshold_warning
  }
}
