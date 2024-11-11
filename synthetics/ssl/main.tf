locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_synthetics_test" "ssl" {
  count = var.ssl_synthetic_enabled ? 1 : 0

  name      = join("", [local.title_prefix, "SSL Certificate expiration - ${var.ssl_synthetic_host}", local.title_suffix])
  type      = "api"
  subtype   = "ssl"
  status    = "live"
  message = <<-EOT
    {{#is_alert}}
    ${local.notify_on_prod}
    SSL certificate is expiring in less than {{threshold}} days.
    Please renew the certificate to prevent service disruption.
    {{/is_alert}}

    {{#is_recovery}}
    ${local.notify_on_prod}
    SSL certificate has been renewed and is no longer at risk of expiring.
    {{/is_recovery}}
    EOT
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

  dynamic "assertion" {
    for_each = var.ssl_synthetic_tls_check_enabled ? [1] : []
    content {
      type     = "tlsVersion"
      operator = "moreThanOrEqual"
      target   = var.ssl_synthetic_min_tls_version
    }
  }

  dynamic "assertion" {
    for_each = var.ssl_synthetic_response_time_check_enabled ? [1] : []
    content {
      type     = "responseTime"
      operator = "lessThan"
      target   = var.ssl_synthetic_max_response_time
    }
  }

  options_list {
    tick_every         = var.ssl_synthetic_tick_every
    accept_self_signed = var.ssl_synthetic_accept_self_signed

    monitor_options {
      renotify_interval = var.ssl_synthetic_renotify_interval
    }
  }
}
