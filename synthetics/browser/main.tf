locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_synthetics_test" "browser" {
  count = var.browser_synthetic_enabled ? 1 : 0

  name       = join("", [local.title_prefix, "Browser Test", local.title_suffix])
  type       = "browser"
  status     = "live"
  message    = local.synthetic_alert_base_message
  device_ids = var.browser_synthetic_device_ids
  locations  = var.browser_synthetic_locations
  tags       = concat(local.common_tags, var.base_tags, var.additional_tags)

  request_definition {
    method = "GET"
    url    = var.browser_synthetic_request_url
  }

  dynamic "browser_step" {
    for_each = var.browser_synthetic_steps
    content {
      name = browser_step.value["name"]
      type = browser_step.value["type"]
      dynamic "params" {
        for_each = browser_step.value["params"]
        content {
          value = params.value["value"]
        }
      }
    }
  }

  options_list {
    tick_every = var.browser_synthetic_tick_every
  }
}
