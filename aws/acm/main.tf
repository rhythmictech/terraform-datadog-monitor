locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "certificate_renewal_failure_check" {
  count = var.certificate_renewal_failure_check_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ACM - Certificate Renewal Failure", local.title_suffix])
  type         = "event-v2 alert"
  message      = local.event_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  include_tags = false

  evaluation_delay = var.evaluation_delay
  new_group_delay  = var.new_group_delay

  query = <<-EOQ
    events("source:amazon_acm").rollup("count").by("@aggregation_key,env").last("5m") > 0
  EOQ

  monitor_thresholds {
    critical = 0
  }
}
