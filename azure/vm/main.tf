locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  # `host` is included so platform-metric alerts join cleanly to the agent-based
  # host/* monitors, which are required coverage for filesystem and swap.
  group_by = "name,subscription_name,resource_group,region,host,env,datadog_managed"
}

resource "datadog_monitor" "availability" {
  count = var.availability_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Azure VM availability - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.availability_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.availability_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.availability_evaluation_window}):
      min:azure.vm.vm_availability_metric_preview${local.query_filter} by {${local.group_by}}
    < 1
END

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "cpu_high" {
  count = var.cpu_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Azure VM CPU high - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.vm.percentage_cpu${local.query_filter} by {${local.group_by}}
    > ${var.cpu_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_high_threshold_critical
    warning  = var.cpu_high_threshold_warning
  }
}

resource "datadog_monitor" "memory_low" {
  count = var.memory_low_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Azure VM available memory low - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.memory_low_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.memory_low_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.memory_low_evaluation_window}):
      avg:azure.vm.available_memory_percentage${local.query_filter} by {${local.group_by}}
    < ${var.memory_low_threshold_critical}
END

  monitor_thresholds {
    critical = var.memory_low_threshold_critical
    warning  = var.memory_low_threshold_warning
  }
}

resource "datadog_monitor" "os_disk_iops_saturation" {
  count = var.os_disk_iops_saturation_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Azure VM OS disk IOPS saturated - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.os_disk_iops_saturation_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.os_disk_iops_saturation_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.os_disk_iops_saturation_evaluation_window}):
      avg:azure.vm.os_disk_iops_consumed_percentage${local.query_filter} by {${local.group_by}}
    > ${var.os_disk_iops_saturation_threshold_critical}
END

  monitor_thresholds {
    critical = var.os_disk_iops_saturation_threshold_critical
    warning  = var.os_disk_iops_saturation_threshold_warning
  }
}

resource "datadog_monitor" "data_disk_iops_saturation" {
  count = var.data_disk_iops_saturation_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Azure VM data disk IOPS saturated - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.data_disk_iops_saturation_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.data_disk_iops_saturation_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.data_disk_iops_saturation_evaluation_window}):
      avg:azure.vm.data_disk_iops_consumed_percentage${local.query_filter} by {${local.group_by}}
    > ${var.data_disk_iops_saturation_threshold_critical}
END

  monitor_thresholds {
    critical = var.data_disk_iops_saturation_threshold_critical
    warning  = var.data_disk_iops_saturation_threshold_warning
  }
}

# B-series burstable VMs only; disabled by default because the metric is not
# emitted by other SKUs and would alert on no-data semantics instead.
resource "datadog_monitor" "cpu_credits_low" {
  count = var.cpu_credits_low_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "Azure VM CPU burst credits low - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.cpu_credits_low_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.cpu_credits_low_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.cpu_credits_low_evaluation_window}):
      min:azure.vm.cpu_credits_remaining${local.query_filter} by {${local.group_by}}
    < ${var.cpu_credits_low_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_credits_low_threshold_critical
    warning  = var.cpu_credits_low_threshold_warning
  }
}
