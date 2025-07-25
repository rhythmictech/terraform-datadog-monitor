locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "host_unreachable" {
  count = var.host_unreachable_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Datadog Agent Status - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.host_unreachable_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "service check"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  no_data_timeframe   = "5"
  notify_no_data      = true
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<EOQ
    "datadog.agent.up"${local.service_filter}.by(${local.service_group_by}).last(2).count_by_status()
  EOQ

  monitor_thresholds {
    ok       = 1
    warning  = 1
    critical = 1
  }
}
