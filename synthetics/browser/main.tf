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
      name = browser_step.value.name
      type = browser_step.value.type
      params {
        attribute         = lookup(browser_step.value.params, "attribute", null)
        check             = lookup(browser_step.value.params, "check", null)
        click_type        = lookup(browser_step.value.params, "click_type", null)
        code              = lookup(browser_step.value.params, "code", null)
        delay             = lookup(browser_step.value.params, "delay", null)
        element           = lookup(browser_step.value.params, "element", null)
        email             = lookup(browser_step.value.params, "email", null)
        file              = lookup(browser_step.value.params, "file", null)
        files             = lookup(browser_step.value.params, "files", null)
        modifiers         = lookup(browser_step.value.params, "modifiers", [])
        playing_tab_id    = lookup(browser_step.value.params, "playing_tab_id", null)
        request           = lookup(browser_step.value.params, "request", null)
        subtest_public_id = lookup(browser_step.value.params, "subtest_public_id", null)
        value             = lookup(browser_step.value.params, "value", null)
        with_click        = lookup(browser_step.value.params, "with_click", null)
        x                 = lookup(browser_step.value.params, "x", null)
        y                 = lookup(browser_step.value.params, "y", null)
      }
    }
  }

  options_list {
    tick_every = var.browser_synthetic_tick_every
  }
}
