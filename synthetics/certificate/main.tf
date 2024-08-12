locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_synthetics_test" "ssl" {
  count = var.ssl_synthetic_enabled ? 1 : 0

  name      = join("", [local.title_prefix, "Certificate", local.title_suffix])
  type      = "api"
  subtype   = "ssl"
  status    = "live"
  message   = local.query_alert_base_message
  locations = var.ssl_synthetic_locations
  tags      = concat(local.common_tags, var.base_tags, var.additional_tags)

  request_definition {
    host = var.ssl_synthetic_host
    port = var.ssl_synthetic_port
  }

  assertion {
    type     = "certificate"
    operator = "isInMoreThan"
    target   = var.ssl_synthetic_days_to_expiration
  }

  options_list {
    tick_every         = var.ssl_synthetic_tick_every
    accept_self_signed = var.ssl_synthetic_accept_self_signed
  }
}
