locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "process_alert" {
  count = var.process_alert_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Process Alert - {{host.name}}", local.title_suffix])
  message = local.query_alert_base_message
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)
  type    = "process alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = var.timeout_h
  include_tags        = true
  require_full_window = true

  query = <<EOQ
    processes("${var.process_alert_process_name}")${local.service_filter}.by("host").rollup("count").last(${var.process_alert_timeframe})
      ${var.process_alert_operator} ${var.process_alert_threshold_critical}
  EOQ

  monitor_thresholds {
    warning  = var.process_alert_threshold_warning
    critical = var.process_alert_threshold_critical
  }
}
