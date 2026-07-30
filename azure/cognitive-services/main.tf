locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  # `kind` is what separates an Azure OpenAI account from a Form Recognizer
  # (Document Intelligence) account: both report into this one metric namespace.
  group_by = "name,kind,subscription_name,resource_group,region,env,datadog_managed"
}

resource "datadog_monitor" "error_rate" {
  count = var.error_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Cognitive Services error rate - {{name.name}} ({{kind.name}}) - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.error_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.error_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.error_rate_evaluation_window}):
      default(avg:azure.cognitiveservices_accounts.total_errors${local.query_filter} by {${local.group_by}}.as_rate(), 0) / (
      default(avg:azure.cognitiveservices_accounts.total_calls${local.query_filter} by {${local.group_by}}.as_rate(), 1)
    ) * 100 > ${var.error_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.error_rate_threshold_critical
    warning  = var.error_rate_threshold_warning
  }
}

resource "datadog_monitor" "availability_rate" {
  count = var.availability_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Cognitive Services availability - {{name.name}} ({{kind.name}}) - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.availability_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.availability_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.availability_rate_evaluation_window}):
      avg:azure.cognitiveservices_accounts.availability_rate${local.query_filter} by {${local.group_by}}
    < ${var.availability_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.availability_rate_threshold_critical
    warning  = var.availability_rate_threshold_warning
  }
}

# Blocked calls are the quota / rate-limit rejection signal and are actionable
# regardless of how the account is provisioned.
resource "datadog_monitor" "blocked_calls" {
  count = var.blocked_calls_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Cognitive Services blocked calls - {{name.name}} ({{kind.name}}) - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.blocked_calls_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.blocked_calls_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.blocked_calls_evaluation_window}):
      default(sum:azure.cognitiveservices_accounts.blocked_calls${local.query_filter} by {${local.group_by}}.as_count(), 0)
    > ${var.blocked_calls_threshold_critical}
END

  monitor_thresholds {
    critical = var.blocked_calls_threshold_critical
  }
}

# Disabled by default: Datadog does not document the unit for this metric. The
# thresholds below assume milliseconds; confirm against live data first.
resource "datadog_monitor" "latency" {
  count = var.latency_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Cognitive Services latency - {{name.name}} ({{kind.name}}) - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.latency_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.latency_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.latency_evaluation_window}):
      avg:azure.cognitiveservices_accounts.latency${local.query_filter} by {${local.group_by}}
    > ${var.latency_threshold_critical}
END

  monitor_thresholds {
    critical = var.latency_threshold_critical
    warning  = var.latency_threshold_warning
  }
}

# Disabled by default: only emitted by provisioned-throughput (PTU) deployments.
resource "datadog_monitor" "provisioned_utilization" {
  count = var.provisioned_utilization_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Cognitive Services provisioned utilization - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.provisioned_utilization_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.provisioned_utilization_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.provisioned_utilization_evaluation_window}):
      avg:azure.cognitiveservices_accounts.provisioned_utilization${local.query_filter} by {${local.group_by}}
    > ${var.provisioned_utilization_threshold_critical}
END

  monitor_thresholds {
    critical = var.provisioned_utilization_threshold_critical
    warning  = var.provisioned_utilization_threshold_warning
  }
}

# Disabled by default: Azure OpenAI deployments only.
resource "datadog_monitor" "model_availability_rate" {
  count = var.model_availability_rate_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Cognitive Services model availability - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.model_availability_rate_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.model_availability_rate_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.model_availability_rate_evaluation_window}):
      avg:azure.cognitiveservices_accounts.model_availability_rate${local.query_filter} by {${local.group_by}}
    < ${var.model_availability_rate_threshold_critical}
END

  monitor_thresholds {
    critical = var.model_availability_rate_threshold_critical
    warning  = var.model_availability_rate_threshold_warning
  }
}
