locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  group_by = "name,subscription_name,resource_group,region,env,datadog_managed"

  # `requests` reports every status class under one metric name, discriminated by
  # a status-class dimension, so the 5xx numerator needs that tag in addition to
  # the shared include/exclude filter.
  #
  # `local.query_filter` from common.tf already renders complete with braces and
  # is exactly "{*}" when no include or exclude tags are set, so splice rather
  # than concatenate: "{*,statuscodecategory:5xx}" is not valid Datadog syntax.
  #
  # Azure names this dimension `statusCodeCategory`, in camelCase, so the assumed
  # lowercase Datadog key here carries the highest tag-spelling risk in the
  # module. Both key and value are variables. See the README.
  http_5xx_dimension = "${var.http_5xx_rate_status_tag_key}:${var.http_5xx_rate_status_tag_value}"
  http_5xx_filter    = local.query_filter == "{*}" ? "{${local.http_5xx_dimension}}" : replace(local.query_filter, "}", ",${local.http_5xx_dimension}}")
}

# The Jira scope's "pod restarts" signal, which has no equivalent in the AKS
# platform namespace.
#
# `RestartCount` is CUMULATIVE: Azure documents it as "the cumulative number of
# times the replica has restarted since it was created". Alerting on the raw
# value would latch, staying triggered for the whole life of any replica that
# ever crossed the threshold, and would score a replica that restarted six times
# over three months identically to one crash-looping right now.
#
# `monotonic_diff()` converts it to the per-interval increase, counting only
# positive deltas so a replica replacement (counter reset to 0) does not register
# as a negative spike. That is the correct treatment for a monotonic counter.
resource "datadog_monitor" "restart_count_high" {
  count = var.restart_count_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App replica restarts - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.restart_count_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.restart_count_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.restart_count_high_evaluation_window}):
      monotonic_diff(max:azure.app_containerapps.restart_count${local.query_filter} by {${local.group_by}})
    > ${var.restart_count_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.restart_count_high_threshold_critical
    warning  = var.restart_count_high_threshold_warning
  }
}

# The Jira scope's "replica availability" signal, which likewise has no
# equivalent in the AKS platform namespace.
#
# Compared with `<`, so the warning threshold sits ABOVE the critical one.
resource "datadog_monitor" "replicas_low" {
  count = var.replicas_low_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App running replicas low - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.replicas_low_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.replicas_low_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.replicas_low_evaluation_window}):
      min:azure.app_containerapps.replicas${local.query_filter} by {${local.group_by}}
    < ${var.replicas_low_threshold_critical}
END

  monitor_thresholds {
    critical = var.replicas_low_threshold_critical
    warning  = var.replicas_low_threshold_warning
  }
}

resource "datadog_monitor" "cpu_high" {
  count = var.cpu_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App CPU high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.cpu_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cpu_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.cpu_high_evaluation_window}):
      avg:azure.app_containerapps.cpu_percentage${local.query_filter} by {${local.group_by}}
    > ${var.cpu_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_high_threshold_critical
    warning  = var.cpu_high_threshold_warning
  }
}

resource "datadog_monitor" "memory_high" {
  count = var.memory_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App memory high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.memory_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.memory_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.memory_high_evaluation_window}):
      avg:azure.app_containerapps.memory_percentage${local.query_filter} by {${local.group_by}}
    > ${var.memory_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.memory_high_threshold_critical
    warning  = var.memory_high_threshold_warning
  }
}

# Note the unit is MILLISECONDS, unlike azure/app-service and azure/functions
# where `average_response_time` is in seconds. Thresholds here are 1000x those.
resource "datadog_monitor" "response_time_high" {
  count = var.response_time_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App response time high - {{name.name}} - {{value}}ms", local.title_suffix])
  include_tags = false
  message      = var.response_time_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.response_time_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.response_time_high_evaluation_window}):
      avg:azure.app_containerapps.response_time${local.query_filter} by {${local.group_by}}
    > ${var.response_time_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.response_time_high_threshold_critical
    warning  = var.response_time_high_threshold_warning
  }
}

# Depends on an unconfirmed dimension tag pair, and on the camelCase-to-lowercase
# key assumption specifically. See the locals block and the README: if the key or
# value is wrong this query returns nothing, and because `notify_no_data`
# defaults to false that failure is silent.
resource "datadog_monitor" "http_5xx_rate" {
  count = var.http_5xx_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App 5xx rate - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.http_5xx_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.http_5xx_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.http_5xx_rate_evaluation_window}):
      default(avg:azure.app_containerapps.requests${local.http_5xx_filter} by {${local.group_by}}.as_rate(), 0) / (
      default(avg:azure.app_containerapps.requests${local.query_filter} by {${local.group_by}}.as_rate(), 1)
    ) * 100 > ${var.http_5xx_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_5xx_rate_threshold_critical
    warning  = var.http_5xx_rate_threshold_warning
  }
}

# Disabled by default: this is the ONLY metric in this module that requires the
# Datadog Serverless Agent to be deployed inside the container app, either as a
# sidecar or wrapping the application container. Without it the metric is never
# emitted.
#
# Note the namespace: `azure.containerapps.enhanced.*`, with NO `app_` infix,
# unlike every other metric here. That is how Datadog documents it. Do not
# "correct" it to azure.app_containerapps.enhanced.cold_start, which does not
# exist.
resource "datadog_monitor" "cold_start_high" {
  count = var.cold_start_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App cold starts - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.cold_start_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cold_start_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.cold_start_high_evaluation_window}):
      sum:azure.containerapps.enhanced.cold_start${local.query_filter}.as_count() by {${local.group_by}}
    > ${var.cold_start_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.cold_start_high_threshold_critical
    warning  = var.cold_start_high_threshold_warning
  }
}

# Disabled by default: the resiliency metric family is only emitted when a
# resiliency policy is configured on the container app.
resource "datadog_monitor" "resiliency_request_timeouts" {
  count = var.resiliency_request_timeouts_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App request timeouts - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.resiliency_request_timeouts_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.resiliency_request_timeouts_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.resiliency_request_timeouts_evaluation_window}):
      sum:azure.app_containerapps.resiliency_request_timeouts${local.query_filter}.as_count() by {${local.group_by}}
    > ${var.resiliency_request_timeouts_threshold_critical}
END

  monitor_thresholds {
    critical = var.resiliency_request_timeouts_threshold_critical
    warning  = var.resiliency_request_timeouts_threshold_warning
  }
}

# Disabled by default: same resiliency-policy feature gate. Any ejected host is
# actionable, so the default threshold is 0 and the query compares with `>`.
resource "datadog_monitor" "resiliency_ejected_hosts" {
  count = var.resiliency_ejected_hosts_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App ejected hosts - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.resiliency_ejected_hosts_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.resiliency_ejected_hosts_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.resiliency_ejected_hosts_evaluation_window}):
      max:azure.app_containerapps.resiliency_ejected_hosts${local.query_filter} by {${local.group_by}}
    > ${var.resiliency_ejected_hosts_threshold_critical}
END

  monitor_thresholds {
    critical = var.resiliency_ejected_hosts_threshold_critical
  }
}

# Disabled by default: GPU workloads only.
resource "datadog_monitor" "gpu_utilization_high" {
  count = var.gpu_utilization_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Container App GPU utilization high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.gpu_utilization_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.gpu_utilization_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.gpu_utilization_high_evaluation_window}):
      avg:azure.app_containerapps.gpu_utilization_percentage${local.query_filter} by {${local.group_by}}
    > ${var.gpu_utilization_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.gpu_utilization_high_threshold_critical
    warning  = var.gpu_utilization_high_threshold_warning
  }
}
