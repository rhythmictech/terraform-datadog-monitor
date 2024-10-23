locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"
}

resource "datadog_monitor" "status_failed_check" {
  count = var.status_failed_check_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "EC2 instance status - status check failure - {{name.name}}({{instance_id.name}})", local.title_suffix])
  include_tags = false
  message      = var.status_failed_check_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.status_failed_check_evaluation_window}):
      max:aws.ec2.status_check_failed${local.query_filter} by {aws_account,env,instance_id,name,region,env,datadog_managed}
    >= 1
END

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "status_failed_instance" {
  count = var.status_failed_instance_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "EC2 instance status - instance failure - {{name.name}}({{instance_id.name}})", local.title_suffix])
  include_tags = false
  message      = var.status_failed_instance_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.status_failed_instance_evaluation_window}):
      max:aws.ec2.status_check_failed_instance${local.query_filter} by {aws_account,env,instance_id,name,region,env,datadog_managed}
    >= 1
END

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "status_failed_system" {
  count = var.status_failed_system_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "EC2 instance status - host failure - {{name.name}}({{instance_id.name}})", local.title_suffix])
  include_tags = false
  message      = var.status_failed_system_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.status_failed_system_evaluation_window}):
      max:aws.ec2.status_check_failed_system${local.query_filter} by {aws_account,env,instance_id,name,region,env,datadog_managed}
    >= 1
END

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "status_failed_volume" {
  count = var.status_failed_volume_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "EC2 instance status - volume failure - {{name.name}}({{instance_id.name}})", local.title_suffix])
  include_tags = false
  message      = var.status_failed_volume_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = false
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.status_failed_volume_evaluation_window}):
      max:aws.ec2.status_check_failed_attached_ebs${local.query_filter} by {aws_account,env,instance_id,name,region,env,datadog_managed}
    >= 1
END

  monitor_thresholds {
    critical = 1
  }
}
