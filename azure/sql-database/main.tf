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

  name         = join("", [local.title_prefix, "SQL Database CPU high - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.sql_servers_databases.cpu_percent${local.query_filter} by {${local.group_by}}
    > ${var.cpu_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.cpu_high_threshold_critical
    warning  = var.cpu_high_threshold_warning
  }
}

resource "datadog_monitor" "storage_high" {
  count = var.storage_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Database storage high - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.sql_servers_databases.storage_percent${local.query_filter} by {${local.group_by}}
    > ${var.storage_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.storage_high_threshold_critical
    warning  = var.storage_high_threshold_warning
  }
}

# The metric is `deadlock`, singular.
resource "datadog_monitor" "deadlocks" {
  count = var.deadlocks_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Database deadlocks - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.deadlocks_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.deadlocks_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.deadlocks_evaluation_window}):
      sum:azure.sql_servers_databases.deadlock${local.query_filter}.as_count() by {${local.group_by}}
    > ${var.deadlocks_threshold_critical}
END

  monitor_thresholds {
    critical = var.deadlocks_threshold_critical
    warning  = var.deadlocks_threshold_warning
  }
}

resource "datadog_monitor" "connection_failures" {
  count = var.connection_failures_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Database connection failures - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.connection_failures_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.connection_failures_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.connection_failures_evaluation_window}):
      sum:azure.sql_servers_databases.connection_failed${local.query_filter}.as_count() by {${local.group_by}}
    > ${var.connection_failures_threshold_critical}
END

  monitor_thresholds {
    critical = var.connection_failures_threshold_critical
    warning  = var.connection_failures_threshold_warning
  }
}

resource "datadog_monitor" "workers_high" {
  count = var.workers_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Database worker utilization high - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.sql_servers_databases.workers_percent${local.query_filter} by {${local.group_by}}
    > ${var.workers_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.workers_high_threshold_critical
    warning  = var.workers_high_threshold_warning
  }
}

resource "datadog_monitor" "sessions_high" {
  count = var.sessions_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Database session utilization high - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.sql_servers_databases.sessions_percent${local.query_filter} by {${local.group_by}}
    > ${var.sessions_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.sessions_high_threshold_critical
    warning  = var.sessions_high_threshold_warning
  }
}

# Disabled by default: write-heavy batch and ETL workloads saturate the log
# writer legitimately, so this pages on normal operation unless tuned per
# database.
resource "datadog_monitor" "log_write_high" {
  count = var.log_write_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Database log write utilization high - {{name.name}} - {{value}}%", local.title_suffix])
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
      avg:azure.sql_servers_databases.log_write_percent${local.query_filter} by {${local.group_by}}
    > ${var.log_write_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.log_write_high_threshold_critical
    warning  = var.log_write_high_threshold_warning
  }
}

# Disabled by default: DTU metrics exist only under the DTU purchasing model.
# A vCore database emits nothing here, so leaving it on would create a silent
# no-data monitor. Use cpu_high, which is valid under both models.
resource "datadog_monitor" "dtu_consumption_high" {
  count = var.dtu_consumption_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "SQL Database DTU consumption high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.dtu_consumption_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.dtu_consumption_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.dtu_consumption_high_evaluation_window}):
      avg:azure.sql_servers_databases.dtu_consumption_percent${local.query_filter} by {${local.group_by}}
    > ${var.dtu_consumption_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.dtu_consumption_high_threshold_critical
    warning  = var.dtu_consumption_high_threshold_warning
  }
}
