locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "swap" {
  count = var.swap_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Usable Swap - {{name.name}}", local.title_suffix])
  message      = var.swap_use_message ? local.query_alert_base_message : ""
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)
  type    = "query alert"

  query = <<EOQ
    ${var.swap_time_aggregator}(${var.swap_timeframe}):
      avg:system.swap.pct_free${local.query_filter} by {name,aws_account,env,datadog_managed}
    < ${var.swap_threshold_critical}
  EOQ

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = var.timeout_h
  include_tags        = false
  require_full_window = true

  monitor_thresholds {
    warning  = var.swap_threshold_warning
    critical = var.swap_threshold_critical
  }
}
