locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "tunnel_state" {
  count = var.tunnel_state_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "VPN tunnel state - {{host.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.tunnel_state_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.tunnel_state_evaluation_window}):(
      min:aws.vpn.tunnel_state${local.query_filter} by {tunnelipaddress,region,env,datadog_critical}
    ) <= 0
END

  monitor_thresholds {
    critical = 0
  }
}
