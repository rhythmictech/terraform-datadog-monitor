locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "memory" {
  count = var.memory_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Usable Memory - {{host.name}}", local.title_suffix])
  message = local.query_alert_base_message
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)
  type    = "query alert"

  query = <<EOQ
    ${var.memory_time_aggregator}(${var.memory_timeframe}):
      avg:system.mem.usable${local.query_filter} by {host} /
      avg:system.mem.total${local.query_filter} by {host} * 100
    < ${var.memory_threshold_critical}
  EOQ

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = var.timeout_h
  include_tags        = true
  require_full_window = true

  monitor_thresholds {
    warning  = var.memory_threshold_warning
    critical = var.memory_threshold_critical
  }
}
