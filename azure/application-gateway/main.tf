locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  group_by = "name,subscription_name,resource_group,region,env,datadog_managed"

  # `backend_response_status` reports every status class under one metric name,
  # discriminated by a status-group dimension, so the 5xx numerator needs that
  # tag in addition to the shared include/exclude filter. `local.query_filter`
  # from common.tf already renders complete with braces, and is exactly "{*}"
  # when no include or exclude tags are set, so splice rather than concatenate:
  # "{*,tag:5xx}" is not valid Datadog filter syntax.
  backend_5xx_filter = local.query_filter == "{*}" ? "{${var.backend_5xx_rate_status_tag}:5xx}" : replace(local.query_filter, "}", ",${var.backend_5xx_rate_status_tag}:5xx}")
}

# Any unhealthy backend is actionable, so the default threshold is 0 rather
# than a count. Compare with `>` so `> 0` means "one or more".
resource "datadog_monitor" "unhealthy_hosts" {
  count = var.unhealthy_hosts_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Application Gateway unhealthy backends - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.unhealthy_hosts_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.unhealthy_hosts_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.unhealthy_hosts_evaluation_window}):
      max:azure.network_applicationgateways.unhealthy_host_count${local.query_filter} by {${local.group_by}}
    > ${var.unhealthy_hosts_threshold_critical}
END

  monitor_thresholds {
    critical = var.unhealthy_hosts_threshold_critical
  }
}

resource "datadog_monitor" "healthy_hosts_low" {
  count = var.healthy_hosts_low_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Application Gateway healthy backends low - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.healthy_hosts_low_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.healthy_hosts_low_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.healthy_hosts_low_evaluation_window}):
      min:azure.network_applicationgateways.healthy_host_count${local.query_filter} by {${local.group_by}}
    < ${var.healthy_hosts_low_threshold_critical}
END

  monitor_thresholds {
    critical = var.healthy_hosts_low_threshold_critical
    warning  = var.healthy_hosts_low_threshold_warning
  }
}

# The enabled-by-default error signal, chosen precisely because it needs no
# status-group dimension filter. See backend_5xx_rate below.
resource "datadog_monitor" "failed_requests" {
  count = var.failed_requests_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Application Gateway failed requests - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.failed_requests_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.failed_requests_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.failed_requests_evaluation_window}):
      sum:azure.network_applicationgateways.failed_requests${local.query_filter}.as_count() by {${local.group_by}}
    > ${var.failed_requests_threshold_critical}
END

  monitor_thresholds {
    critical = var.failed_requests_threshold_critical
    warning  = var.failed_requests_threshold_warning
  }
}

# Disabled by default. `backend_response_status` is a single metric carrying a
# status-group dimension rather than one metric per class, so this query depends
# on the Datadog tag key for that dimension. Azure names the dimension
# HttpStatusGroup; the Datadog tag key is assumed to be `httpstatusgroup` but has
# not been confirmed against live data. Confirm it before enabling, otherwise the
# query silently returns nothing.
resource "datadog_monitor" "backend_5xx_rate" {
  count = var.backend_5xx_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Application Gateway backend 5xx rate - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.backend_5xx_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.backend_5xx_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.backend_5xx_rate_evaluation_window}):
      default(avg:azure.network_applicationgateways.backend_response_status${local.backend_5xx_filter} by {${local.group_by}}.as_rate(), 0) / (
      default(avg:azure.network_applicationgateways.total_requests${local.query_filter} by {${local.group_by}}.as_rate(), 1)
    ) * 100 > ${var.backend_5xx_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.backend_5xx_rate_threshold_critical
    warning  = var.backend_5xx_rate_threshold_warning
  }
}

# Disabled by default: available only on the V2 SKU.
resource "datadog_monitor" "backend_latency" {
  count = var.backend_latency_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Application Gateway backend latency high - {{name.name}} - {{value}}ms", local.title_suffix])
  include_tags = false
  message      = var.backend_latency_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.backend_latency_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.backend_latency_evaluation_window}):
      avg:azure.network_applicationgateways.backend_connect_time${local.query_filter} by {${local.group_by}}
    > ${var.backend_latency_threshold_critical}
END

  monitor_thresholds {
    critical = var.backend_latency_threshold_critical
    warning  = var.backend_latency_threshold_warning
  }
}

# Disabled by default: available only on the V2 SKU, and the meaningful ceiling
# depends on the configured maximum instance count.
resource "datadog_monitor" "capacity_units_high" {
  count = var.capacity_units_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Application Gateway capacity units high - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.capacity_units_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.capacity_units_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.capacity_units_high_evaluation_window}):
      avg:azure.network_applicationgateways.capacity_units${local.query_filter} by {${local.group_by}}
    > ${var.capacity_units_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.capacity_units_high_threshold_critical
    warning  = var.capacity_units_high_threshold_warning
  }
}

# Disabled by default: available only on the V1 SKU, which Azure has retired for
# new deployments.
resource "datadog_monitor" "cpu_utilization_high" {
  count = var.cpu_utilization_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Application Gateway CPU high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.cpu_utilization_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cpu_utilization_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.cpu_utilization_high_evaluation_window}):
      avg:azure.network_applicationgateways.cpu_utilization${local.query_filter} by {${local.group_by}}
    > ${var.cpu_utilization_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_utilization_high_threshold_critical
    warning  = var.cpu_utilization_high_threshold_warning
  }
}
