locals {
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "systemd_unit" {
  count = var.systemd_unit_alert_enabled ? 1 : 0

  name    = join("", [local.title_prefix, "Systemd Unit Status - {{host.name}}", local.title_suffix])
  type    = "service check"
  message = var.systemd_unit_alert_use_message ? local.query_alert_base_message : ""
  tags    = concat(local.common_tags, var.base_tags, var.additional_tags)

  evaluation_delay    = var.evaluation_delay
  notify_no_data      = false
  notify_audit        = false
  renotify_interval   = 60
  timeout_h           = var.timeout_h
  include_tags        = false
  require_full_window = false

  query = <<EOT
"systemd.unit.state"${local.service_filter}.by("host","unit").last(3).count_by_status()
EOT

  monitor_thresholds {
    critical = var.systemd_unit_alert_threshold_critical
    warning  = var.systemd_unit_alert_threshold_warning
  }
}