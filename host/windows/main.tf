locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "windows_service" {
  count = var.windows_service_alert_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Windows Service Alert - {{host.name}}", local.title_suffix])
  message = var.windows_service_alert_use_message ? local.query_alert_base_message : ""
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)
  type    = "service check"

  evaluation_delay    = var.evaluation_delay
  notify_no_data      = false
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = var.timeout_h
  include_tags        = false
  require_full_window = true

  query = <<EOQ
    service_check("windows_service.state")${local.service_filter}.last("${var.windows_service_alert_timeframe}") ${var.windows_service_alert_operator} ${var.windows_service_alert_threshold_critical}
  EOQ

  monitor_thresholds {
    warning  = var.windows_service_alert_threshold_warning
    critical = var.windows_service_alert_threshold_critical
  }
}
