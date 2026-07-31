locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  group_by = "name,subscription_name,resource_group,region,env,datadog_managed"
}

resource "datadog_monitor" "cpu_high" {
  count = var.cpu_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Elastic Pool CPU high - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.sql_servers_elasticpools.cpu_percent${local.query_filter} by {${local.group_by}}
    > ${var.cpu_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_high_threshold_critical
    warning  = var.cpu_high_threshold_warning
  }
}

resource "datadog_monitor" "storage_high" {
  count = var.storage_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Elastic Pool storage high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.storage_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.storage_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.storage_high_evaluation_window}):
      avg:azure.sql_servers_elasticpools.storage_percent${local.query_filter} by {${local.group_by}}
    > ${var.storage_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.storage_high_threshold_critical
    warning  = var.storage_high_threshold_warning
  }
}

resource "datadog_monitor" "workers_high" {
  count = var.workers_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Elastic Pool worker utilization high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.workers_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.workers_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.workers_high_evaluation_window}):
      avg:azure.sql_servers_elasticpools.workers_percent${local.query_filter} by {${local.group_by}}
    > ${var.workers_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.workers_high_threshold_critical
    warning  = var.workers_high_threshold_warning
  }
}

resource "datadog_monitor" "sessions_high" {
  count = var.sessions_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Elastic Pool session utilization high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.sessions_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.sessions_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.sessions_high_evaluation_window}):
      avg:azure.sql_servers_elasticpools.sessions_percent${local.query_filter} by {${local.group_by}}
    > ${var.sessions_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.sessions_high_threshold_critical
    warning  = var.sessions_high_threshold_warning
  }
}

# Disabled by default: write-heavy batch and ETL workloads saturate the log
# writer during normal operation.
resource "datadog_monitor" "log_write_high" {
  count = var.log_write_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Elastic Pool log write utilization high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.log_write_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.log_write_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.log_write_high_evaluation_window}):
      avg:azure.sql_servers_elasticpools.log_write_percent${local.query_filter} by {${local.group_by}}
    > ${var.log_write_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.log_write_high_threshold_critical
    warning  = var.log_write_high_threshold_warning
  }
}

# Disabled by default: read-heavy pools sit near the data IO ceiling by design,
# so this is informational unless the pool is known to be IO constrained.
resource "datadog_monitor" "data_io_high" {
  count = var.data_io_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Elastic Pool data IO high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.data_io_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.data_io_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.data_io_high_evaluation_window}):
      avg:azure.sql_servers_elasticpools.physical_data_read_percent${local.query_filter} by {${local.group_by}}
    > ${var.data_io_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.data_io_high_threshold_critical
    warning  = var.data_io_high_threshold_warning
  }
}

# Disabled by default: eDTU metrics exist only under the DTU purchasing model.
# A vCore pool emits nothing here. Use cpu_high, which is valid under both.
resource "datadog_monitor" "edtu_consumption_high" {
  count = var.edtu_consumption_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Elastic Pool eDTU consumption high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.edtu_consumption_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.edtu_consumption_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.edtu_consumption_high_evaluation_window}):
      avg:azure.sql_servers_elasticpools.dtu_consumption_percent${local.query_filter} by {${local.group_by}}
    > ${var.edtu_consumption_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.edtu_consumption_high_threshold_critical
    warning  = var.edtu_consumption_high_threshold_warning
  }
}
