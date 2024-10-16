locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "http_5xx_responses" {
  count = var.http_5xx_responses_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "API Gateway 5xx Responses - {{apiname.name}}", local.title_suffix])
  include_tags = false
  message      = var.http_5xx_responses_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.http_5xx_responses_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.http_5xx_responses_evaluation_window}):
      default(avg:aws.apigateway.5xxerror{${local.query_filter}} by {stage,apiname,region,aws_account,env,datadog_managed}.as_rate(), 0) / (
      default(avg:aws.apigateway.count{${local.query_filter}} by {stage,apiname,region,aws_account,env,datadog_managed}.as_rate(), 1)
    ) * 100 > ${var.http_5xx_responses_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_5xx_responses_threshold_critical
    warning  = var.http_5xx_responses_threshold_warning
  }
}

resource "datadog_monitor" "latency" {
  count = var.latency_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "API Gateway latency - {{apiname.name}}", local.title_suffix])
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
      default(avg:aws.apigateway.latency{${local.query_filter}} by {stage,apiname,region,aws_account,env,datadog_managed}, 0)
    ) > ${var.latency_threshold_critical}
END

  monitor_thresholds {
    critical = var.latency_threshold_critical
    warning  = var.latency_threshold_warning
  }
}
