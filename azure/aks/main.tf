locals {
  # these must be defined but do not need to be overridden
  monitor_alert_default_priority  = null
  monitor_warn_default_priority   = null
  monitor_nodata_default_priority = null

  title_prefix = var.title_prefix == null ? "" : "[${var.title_prefix}]"
  title_suffix = var.title_suffix == null ? "" : " (${var.title_suffix})"

  group_by = "name,subscription_name,resource_group,region,env,datadog_managed"

  # `kube_pod_status_phase` and `kube_node_status_condition` each report every
  # state under one metric name, discriminated by a dimension, so these monitors
  # need that dimension in addition to the shared include/exclude filter.
  #
  # `local.query_filter` from common.tf already renders complete with braces and
  # is exactly "{*}" when no include or exclude tags are set, so splice rather
  # than concatenate: "{*,phase:Failed}" is not valid Datadog filter syntax.
  #
  # Both the tag key and the tag value are variables. Azure spells these
  # dimensions lowercase, but Kubernetes capitalises the VALUES (`Failed`,
  # `Pending`, `Ready`) and Datadog normalises tag values to lowercase in some
  # integrations. Which it does here is unconfirmed, so the pair must be
  # correctable without a module release. See the README.
  pods_failed_dimension  = "${var.pods_failed_phase_tag_key}:${var.pods_failed_phase_tag_value}"
  pods_pending_dimension = "${var.pods_pending_phase_tag_key}:${var.pods_pending_phase_tag_value}"
  nodes_not_ready_dimension = join(",", [
    "${var.nodes_not_ready_condition_tag_key}:${var.nodes_not_ready_condition_tag_value}",
    "${var.nodes_not_ready_status_tag_key}:${var.nodes_not_ready_status_tag_value}"
  ])

  pods_failed_filter     = local.query_filter == "{*}" ? "{${local.pods_failed_dimension}}" : replace(local.query_filter, "}", ",${local.pods_failed_dimension}}")
  pods_pending_filter    = local.query_filter == "{*}" ? "{${local.pods_pending_dimension}}" : replace(local.query_filter, "}", ",${local.pods_pending_dimension}}")
  nodes_not_ready_filter = local.query_filter == "{*}" ? "{${local.nodes_not_ready_dimension}}" : replace(local.query_filter, "}", ",${local.nodes_not_ready_dimension}}")
}

resource "datadog_monitor" "node_cpu_high" {
  count = var.node_cpu_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS node CPU high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.node_cpu_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.node_cpu_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.node_cpu_high_evaluation_window}):
      avg:azure.containerservice_managedclusters.node_cpu_usage_percentage${local.query_filter} by {${local.group_by}}
    > ${var.node_cpu_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.node_cpu_high_threshold_critical
    warning  = var.node_cpu_high_threshold_warning
  }
}

# Working set, not RSS: the kubelet evicts pods based on working set memory, so
# it is the metric that predicts eviction.
resource "datadog_monitor" "node_memory_working_set_high" {
  count = var.node_memory_working_set_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS node memory working set high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.node_memory_working_set_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.node_memory_working_set_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.node_memory_working_set_high_evaluation_window}):
      avg:azure.containerservice_managedclusters.node_memory_working_set_percentage${local.query_filter} by {${local.group_by}}
    > ${var.node_memory_working_set_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.node_memory_working_set_high_threshold_critical
    warning  = var.node_memory_working_set_high_threshold_warning
  }
}

# Lower thresholds than CPU and memory on purpose: the kubelet starts evicting
# pods under disk pressure and can stop reporting entirely on a full disk, so
# 85 is already late. Aggregated with `max` because the metric carries a
# per-device dimension and one full device is enough to cause trouble.
resource "datadog_monitor" "node_disk_high" {
  count = var.node_disk_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS node disk usage high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.node_disk_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.node_disk_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    max(${var.node_disk_high_evaluation_window}):
      max:azure.containerservice_managedclusters.node_disk_usage_percentage${local.query_filter} by {${local.group_by}}
    > ${var.node_disk_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.node_disk_high_threshold_critical
    warning  = var.node_disk_high_threshold_warning
  }
}

# A throttled API server stalls every controller in the cluster, so this is a
# cluster-wide availability signal rather than a capacity one.
resource "datadog_monitor" "apiserver_cpu_high" {
  count = var.apiserver_cpu_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS API server CPU high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.apiserver_cpu_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.apiserver_cpu_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.apiserver_cpu_high_evaluation_window}):
      max:azure.containerservice_managedclusters.apiserver_cpu_usage_percentage${local.query_filter} by {${local.group_by}}
    > ${var.apiserver_cpu_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.apiserver_cpu_high_threshold_critical
    warning  = var.apiserver_cpu_high_threshold_warning
  }
}

resource "datadog_monitor" "apiserver_memory_high" {
  count = var.apiserver_memory_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS API server memory high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.apiserver_memory_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.apiserver_memory_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.apiserver_memory_high_evaluation_window}):
      max:azure.containerservice_managedclusters.apiserver_memory_usage_percentage${local.query_filter} by {${local.group_by}}
    > ${var.apiserver_memory_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.apiserver_memory_high_threshold_critical
    warning  = var.apiserver_memory_high_threshold_warning
  }
}

# The highest-value monitor in this module. etcd database usage is driven by the
# client's own object count and size, so unlike the rest of the control plane it
# is genuinely actionable. When the database reaches its quota the cluster goes
# READ-ONLY, and recovery means deleting objects, so the warning threshold is
# deliberately well below the critical one to leave time to act.
resource "datadog_monitor" "etcd_database_usage_high" {
  count = var.etcd_database_usage_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS etcd database usage high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.etcd_database_usage_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.etcd_database_usage_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.etcd_database_usage_high_evaluation_window}):
      max:azure.containerservice_managedclusters.etcd_database_usage_percentage${local.query_filter} by {${local.group_by}}
    > ${var.etcd_database_usage_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.etcd_database_usage_high_threshold_critical
    warning  = var.etcd_database_usage_high_threshold_warning
  }
}

# Any failed pod is actionable, so the default threshold is 0 and the query
# compares with `>`.
#
# Depends on an unconfirmed dimension tag pair. See the locals block and the
# README: if the key or value is wrong this query returns nothing, and because
# `notify_no_data` defaults to false that failure is silent.
resource "datadog_monitor" "pods_failed" {
  count = var.pods_failed_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS failed pods - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.pods_failed_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.pods_failed_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.pods_failed_evaluation_window}):
      sum:azure.containerservice_managedclusters.kube_pod_status_phase${local.pods_failed_filter}.as_count() by {${local.group_by}}
    > ${var.pods_failed_threshold_critical}
END

  monitor_thresholds {
    critical = var.pods_failed_threshold_critical
  }
}

# Longer evaluation window than the module default: pods sit in Pending
# routinely while images pull and volumes attach, so a short window would alert
# on healthy scheduling churn. What matters is pods STAYING pending.
#
# Depends on an unconfirmed dimension tag pair, as above.
resource "datadog_monitor" "pods_pending" {
  count = var.pods_pending_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS pending pods - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.pods_pending_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.pods_pending_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.pods_pending_evaluation_window}):
      sum:azure.containerservice_managedclusters.kube_pod_status_phase${local.pods_pending_filter}.as_count() by {${local.group_by}}
    > ${var.pods_pending_threshold_critical}
END

  monitor_thresholds {
    critical = var.pods_pending_threshold_critical
    warning  = var.pods_pending_threshold_warning
  }
}

# Any not-ready node is actionable, so the default threshold is 0 and the query
# compares with `>`.
#
# This monitor carries TWO unconfirmed dimension pairs, condition and status,
# making it the most fragile in the module. Confirm both before trusting it.
resource "datadog_monitor" "nodes_not_ready" {
  count = var.nodes_not_ready_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS nodes not ready - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.nodes_not_ready_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.nodes_not_ready_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.nodes_not_ready_evaluation_window}):
      sum:azure.containerservice_managedclusters.kube_node_status_condition${local.nodes_not_ready_filter}.as_count() by {${local.group_by}}
    > ${var.nodes_not_ready_threshold_critical}
END

  monitor_thresholds {
    critical = var.nodes_not_ready_threshold_critical
  }
}

# Disabled by default: the cluster autoscaler metrics are only emitted when the
# autoscaler is actually enabled on the cluster. Enable alongside it.
resource "datadog_monitor" "unschedulable_pods" {
  count = var.unschedulable_pods_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS unschedulable pods - {{name.name}} - {{value}}", local.title_suffix])
  include_tags = false
  message      = var.unschedulable_pods_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.unschedulable_pods_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    sum(${var.unschedulable_pods_evaluation_window}):
      sum:azure.containerservice_managedclusters.cluster_autoscaler_unschedulable_pods_count${local.query_filter} by {${local.group_by}}
    > ${var.unschedulable_pods_threshold_critical}
END

  monitor_thresholds {
    critical = var.unschedulable_pods_threshold_critical
  }
}

# Disabled by default: same cluster-autoscaler feature gate as above. The metric
# reports 1 when the autoscaler considers the cluster safe to act on, so alert
# when it drops BELOW 1.
resource "datadog_monitor" "autoscaler_unhealthy" {
  count = var.autoscaler_unhealthy_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS cluster autoscaler unhealthy - {{name.name}}", local.title_suffix])
  include_tags = false
  message      = var.autoscaler_unhealthy_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.autoscaler_unhealthy_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    min(${var.autoscaler_unhealthy_evaluation_window}):
      min:azure.containerservice_managedclusters.cluster_autoscaler_cluster_safe_to_autoscale${local.query_filter} by {${local.group_by}}
    < ${var.autoscaler_unhealthy_threshold_critical}
END

  monitor_thresholds {
    critical = var.autoscaler_unhealthy_threshold_critical
  }
}

# Disabled by default, and NOT because of a feature gate: Azure operates and
# scales the AKS control plane, so etcd CPU is not customer-actionable the way
# etcd DATABASE usage is. Enable it if you want visibility into control-plane
# pressure, but expect to be unable to do much about it.
resource "datadog_monitor" "etcd_cpu_high" {
  count = var.etcd_cpu_high_enabled ? 1 : 0

  name         = join("", [local.title_prefix, "AKS etcd CPU high - {{name.name}} - {{value}}%", local.title_suffix])
  include_tags = false
  message      = var.etcd_cpu_high_use_message ? local.query_alert_base_message : ""
  tags         = concat(local.common_tags, var.base_tags, var.additional_tags)
  type         = "query alert"

  evaluation_delay    = var.evaluation_delay
  new_group_delay     = var.new_group_delay
  notify_no_data      = var.notify_no_data
  no_data_timeframe   = var.etcd_cpu_high_no_data_window
  renotify_interval   = var.renotify_interval
  require_full_window = true
  timeout_h           = var.timeout_h

  query = <<END
    avg(${var.etcd_cpu_high_evaluation_window}):
      max:azure.containerservice_managedclusters.etcd_cpu_usage_percentage${local.query_filter} by {${local.group_by}}
    > ${var.etcd_cpu_high_threshold_critical}
END

  monitor_thresholds {
    critical = var.etcd_cpu_high_threshold_critical
    warning  = var.etcd_cpu_high_threshold_warning
  }
}
