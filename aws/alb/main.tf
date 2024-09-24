locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = "${var.title_prefix == null ? "" : "[${var.title_prefix}]"}[${var.env}] "
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "http_5xx_responses" {
  count = var.http_5xx_responses_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ALB 5xx Responses - {{loadbalancer.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
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
      default(avg:aws.applicationelb.httpcode_elb_5xx${local.query_filter} by {aws_account,env,loadbalancer,region}.as_rate(), 0) / (
      default(avg:aws.applicationelb.request_count${local.query_filter} by {aws_account,env,loadbalancer,region}.as_rate(), 1)
    ) * 100 > ${var.http_5xx_responses_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_5xx_responses_threshold_critical
    warning  = var.http_5xx_responses_threshold_warning
  }
}

resource "datadog_monitor" "http_5xx_tg_responses" {
  count = var.http_5xx_tg_responses_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "ALB Target Group 5xx Responses - {{loadbalancer.name}}", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.http_5xx_tg_responses_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.http_5xx_tg_responses_evaluation_window}):
      default(avg:aws.applicationelb.httpcode_elb_5xx${local.query_filter} by {loadbalancer,region,aws_account,targetgroup,env}.as_rate(), 0) / (
      default(avg:aws.applicationelb.request_count${local.query_filter} by {loadbalancer,region,aws_account,targetgroup,env}.as_rate(), 1)
    ) * 100 > ${var.http_5xx_tg_responses_threshold_critical}
END

  monitor_thresholds {
    critical = var.http_5xx_tg_responses_threshold_critical
    warning  = var.http_5xx_tg_responses_threshold_warning
  }
}


resource "datadog_monitor" "latency" {
  count = var.latency_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "{{loadbalancer.name}} ALB latency - {{value}}s ", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
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
      default(avg:aws.applicationelb.target_response_time.average${local.query_filter} by {aws_account,env,loadbalancer,region}, 0
    ) > ${var.latency_threshold_critical}
END

  monitor_thresholds {
    critical = var.latency_threshold_critical
    warning  = var.latency_threshold_warning
  }
}

resource "datadog_monitor" "no_healthy_instances" {
  count = var.no_healthy_instances_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "{{loadbalancer.name}} ALB healthy instances is at {{value}}%", local.title_suffix])
  include_tags = true
  message      = local.query_alert_base_message
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.no_healthy_instances_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.no_healthy_instances_evaluation_window}): (
      sum:aws.applicationelb.healthy_host_count.minimum${local.query_filter} by {aws_account,env,region,loadbalancer} / (
      sum:aws.applicationelb.healthy_host_count.minimum${local.query_filter} by {aws_account,env,region,loadbalancer} +
      sum:aws.applicationelb.un_healthy_host_count.maximum${local.query_filter} by {aws_account,env,region,loadbalancer} )
    ) * 100 <= ${var.no_healthy_instances_threshold_critical}
END

  monitor_thresholds {
    critical = var.no_healthy_instances_threshold_critical
    warning  = var.no_healthy_instances_threshold_warning
  }
}
