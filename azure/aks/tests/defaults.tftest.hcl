# Requires Terraform >= 1.7 for `mock_provider`, satisfied by the repo's
# .terraform-version pin of latest:^1.9.
mock_provider "datadog" {}

variables {
  notify_default = ["@slack-test"]
}

run "defaults_enable_expected_monitors" {
  command = plan

  assert {
    condition = alltrue([
      length(datadog_monitor.node_cpu_high) == 1,
      length(datadog_monitor.node_memory_working_set_high) == 1,
      length(datadog_monitor.node_disk_high) == 1,
      length(datadog_monitor.apiserver_cpu_high) == 1,
      length(datadog_monitor.apiserver_memory_high) == 1,
      length(datadog_monitor.etcd_database_usage_high) == 1,
      length(datadog_monitor.pods_failed) == 1,
      length(datadog_monitor.pods_pending) == 1,
      length(datadog_monitor.nodes_not_ready) == 1,
    ])
    error_message = "the nine default monitors should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.unschedulable_pods) == 0,
      length(datadog_monitor.autoscaler_unhealthy) == 0,
      length(datadog_monitor.etcd_cpu_high) == 0,
    ])
    error_message = "the two cluster-autoscaler-gated monitors and etcd_cpu_high should be disabled by default"
  }
}

run "queries_target_the_azure_aks_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.node_cpu_usage_percentage", datadog_monitor.node_cpu_high[0].query))
    error_message = "node_cpu_high must query azure.containerservice_managedclusters.node_cpu_usage_percentage"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.node_memory_working_set_percentage", datadog_monitor.node_memory_working_set_high[0].query))
    error_message = "node_memory_working_set_high must query node_memory_working_set_percentage, not the RSS metric"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.node_disk_usage_percentage", datadog_monitor.node_disk_high[0].query))
    error_message = "node_disk_high must query azure.containerservice_managedclusters.node_disk_usage_percentage"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.apiserver_cpu_usage_percentage", datadog_monitor.apiserver_cpu_high[0].query))
    error_message = "apiserver_cpu_high must query azure.containerservice_managedclusters.apiserver_cpu_usage_percentage"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.apiserver_memory_usage_percentage", datadog_monitor.apiserver_memory_high[0].query))
    error_message = "apiserver_memory_high must query azure.containerservice_managedclusters.apiserver_memory_usage_percentage"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.etcd_database_usage_percentage", datadog_monitor.etcd_database_usage_high[0].query))
    error_message = "etcd_database_usage_high must query etcd_database_usage_percentage, not an etcd CPU or memory metric"
  }

  assert {
    condition = alltrue([
      can(regex("azure\\.containerservice_managedclusters\\.kube_pod_status_phase", datadog_monitor.pods_failed[0].query)),
      can(regex("azure\\.containerservice_managedclusters\\.kube_pod_status_phase", datadog_monitor.pods_pending[0].query)),
    ])
    error_message = "both pod-phase monitors must query azure.containerservice_managedclusters.kube_pod_status_phase"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.kube_node_status_condition", datadog_monitor.nodes_not_ready[0].query))
    error_message = "nodes_not_ready must query azure.containerservice_managedclusters.kube_node_status_condition"
  }
}

# This module covers AZURE PLATFORM metrics only. Pod restarts, deployment
# replica availability and container-vs-limit resource usage come from the
# Datadog Agent's Kubernetes integration and are deliberately out of scope, so a
# query reaching into an agent namespace means the boundary has eroded.
run "never_queries_the_agent_namespace" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.node_cpu_high[0].query,
        datadog_monitor.node_memory_working_set_high[0].query,
        datadog_monitor.node_disk_high[0].query,
        datadog_monitor.apiserver_cpu_high[0].query,
        datadog_monitor.apiserver_memory_high[0].query,
        datadog_monitor.etcd_database_usage_high[0].query,
        datadog_monitor.pods_failed[0].query,
        datadog_monitor.pods_pending[0].query,
        datadog_monitor.nodes_not_ready[0].query,
      ] : !can(regex("kubernetes_state|kubernetes\\.", q))
    ])
    error_message = "this module must query Azure platform metrics only, never the Datadog Agent's kubernetes namespaces"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.node_cpu_high[0].query,
        datadog_monitor.node_disk_high[0].query,
        datadog_monitor.etcd_database_usage_high[0].query,
        datadog_monitor.pods_failed[0].query,
        datadog_monitor.nodes_not_ready[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.node_cpu_high[0].query,
        datadog_monitor.node_disk_high[0].query,
        datadog_monitor.etcd_database_usage_high[0].query,
        datadog_monitor.pods_failed[0].query,
        datadog_monitor.nodes_not_ready[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

# local.query_filter from common.tf renders complete with braces, so a dimension
# tag has to be spliced INSIDE the closing brace. Concatenating would produce
# "{*,phase:Failed}", which is invalid Datadog syntax, and appending after the
# brace would drop the user's exclusions.
run "dimension_splice_preserves_exclude_tags" {
  command = plan

  variables {
    monitor_exclude_tags = ["nodepool:system"]
  }

  assert {
    condition = alltrue([
      can(regex("!nodepool:system", datadog_monitor.pods_failed[0].query)),
      can(regex("phase:Failed", datadog_monitor.pods_failed[0].query)),
    ])
    error_message = "the spliced filter must keep the user's exclude tag alongside the dimension filter"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.pods_failed[0].query,
        datadog_monitor.pods_pending[0].query,
        datadog_monitor.nodes_not_ready[0].query,
      ] : !can(regex("\\{\\*,", q))
    ])
    error_message = "the wildcard must never be concatenated with a dimension tag: {*,tag:value} is invalid Datadog syntax"
  }

  assert {
    condition = alltrue([
      can(regex("condition:Ready", datadog_monitor.nodes_not_ready[0].query)),
      can(regex("status:false", datadog_monitor.nodes_not_ready[0].query)),
    ])
    error_message = "nodes_not_ready must splice BOTH the condition and status dimensions"
  }
}

# The run above deliberately sets monitor_exclude_tags, which means
# local.query_filter is NOT "{*}" there and the wildcard branch of the splice is
# never exercised by it. This run must therefore set NO filter variables: with no
# include or exclude tags common.tf renders local.query_filter as exactly "{*}",
# and the dimension filter has to REPLACE that wildcard rather than be appended
# to it, because "{*,phase:Failed}" is invalid Datadog syntax.
run "wildcard_filter_is_replaced_not_concatenated" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.pods_failed[0].query,
        datadog_monitor.pods_pending[0].query,
        datadog_monitor.nodes_not_ready[0].query,
      ] : !can(regex("\\{\\*", q))
    ])
    error_message = "with no include or exclude tags the dimension filter must replace the {*} wildcard, not be concatenated with it"
  }

  assert {
    condition = alltrue([
      can(regex("kube_pod_status_phase\\{phase:Failed\\}", datadog_monitor.pods_failed[0].query)),
      can(regex("kube_pod_status_phase\\{phase:Pending\\}", datadog_monitor.pods_pending[0].query)),
      can(regex("kube_node_status_condition\\{condition:Ready,status:false\\}", datadog_monitor.nodes_not_ready[0].query)),
    ])
    error_message = "the default filter must be exactly the dimension selector"
  }

  # The monitors that take no dimension filter must still carry the plain
  # wildcard, so the assertion above cannot be satisfied by dropping the filter.
  assert {
    condition     = can(regex("node_cpu_usage_percentage\\{\\*\\}", datadog_monitor.node_cpu_high[0].query))
    error_message = "non-dimension monitors must still render the {*} wildcard filter"
  }
}

# The entire containment story for shipping these monitors enabled while their
# tag pairs are unconfirmed. If overriding a key or value does not reach the
# query, a wrong guess becomes a module release rather than a tfvar fix.
run "dimension_tag_keys_and_values_are_overridable" {
  command = plan

  variables {
    pods_failed_phase_tag_key           = "pod_phase"
    pods_failed_phase_tag_value         = "failed"
    pods_pending_phase_tag_value        = "pending"
    nodes_not_ready_condition_tag_value = "ready"
    nodes_not_ready_status_tag_key      = "condition_status"
  }

  assert {
    condition     = can(regex("pod_phase:failed", datadog_monitor.pods_failed[0].query))
    error_message = "overriding both the phase tag key and value must reach the query"
  }

  assert {
    condition     = can(regex("phase:pending", datadog_monitor.pods_pending[0].query))
    error_message = "overriding the pending phase tag value must reach the query"
  }

  assert {
    condition = alltrue([
      can(regex("condition:ready", datadog_monitor.nodes_not_ready[0].query)),
      can(regex("condition_status:false", datadog_monitor.nodes_not_ready[0].query)),
    ])
    error_message = "both nodes_not_ready dimension pairs must be independently overridable"
  }
}

# "Any not-ready node is actionable" must not silently regress to "more than one".
run "nodes_not_ready_uses_a_zero_threshold" {
  command = plan

  assert {
    condition     = tonumber(datadog_monitor.nodes_not_ready[0].monitor_thresholds[0].critical) == 0
    error_message = "nodes_not_ready must default to a critical threshold of 0 so any not-ready node alerts"
  }

  assert {
    condition     = can(regex("> 0", datadog_monitor.nodes_not_ready[0].query))
    error_message = "nodes_not_ready must compare with > 0"
  }

  assert {
    condition     = tonumber(datadog_monitor.pods_failed[0].monitor_thresholds[0].critical) == 0
    error_message = "pods_failed must likewise default to 0 so any failed pod alerts"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    unschedulable_pods_enabled   = true
    autoscaler_unhealthy_enabled = true
    etcd_cpu_high_enabled        = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.unschedulable_pods) == 1,
      length(datadog_monitor.autoscaler_unhealthy) == 1,
      length(datadog_monitor.etcd_cpu_high) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.cluster_autoscaler_unschedulable_pods_count", datadog_monitor.unschedulable_pods[0].query))
    error_message = "unschedulable_pods must query cluster_autoscaler_unschedulable_pods_count"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.cluster_autoscaler_cluster_safe_to_autoscale", datadog_monitor.autoscaler_unhealthy[0].query))
    error_message = "autoscaler_unhealthy must query cluster_autoscaler_cluster_safe_to_autoscale"
  }

  assert {
    condition     = can(regex("< 1", datadog_monitor.autoscaler_unhealthy[0].query))
    error_message = "autoscaler_unhealthy must compare with < since the metric reports 1 when healthy"
  }

  assert {
    condition     = can(regex("azure\\.containerservice_managedclusters\\.etcd_cpu_usage_percentage", datadog_monitor.etcd_cpu_high[0].query))
    error_message = "etcd_cpu_high must query etcd_cpu_usage_percentage"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    node_cpu_high_enabled                = false
    node_memory_working_set_high_enabled = false
    node_disk_high_enabled               = false
    apiserver_cpu_high_enabled           = false
    apiserver_memory_high_enabled        = false
    etcd_database_usage_high_enabled     = false
    pods_failed_enabled                  = false
    pods_pending_enabled                 = false
    nodes_not_ready_enabled              = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.node_cpu_high) == 0,
      length(datadog_monitor.node_memory_working_set_high) == 0,
      length(datadog_monitor.node_disk_high) == 0,
      length(datadog_monitor.apiserver_cpu_high) == 0,
      length(datadog_monitor.apiserver_memory_high) == 0,
      length(datadog_monitor.etcd_database_usage_high) == 0,
      length(datadog_monitor.pods_failed) == 0,
      length(datadog_monitor.pods_pending) == 0,
      length(datadog_monitor.nodes_not_ready) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    node_cpu_high_threshold_critical            = 70
    node_cpu_high_threshold_warning             = 55
    etcd_database_usage_high_threshold_critical = 95
    pods_pending_threshold_critical             = 20
  }

  assert {
    condition     = can(regex("> 70", datadog_monitor.node_cpu_high[0].query))
    error_message = "the query comparison must use the critical threshold"
  }

  assert {
    condition     = tonumber(datadog_monitor.node_cpu_high[0].monitor_thresholds[0].warning) == 55
    error_message = "the warning threshold must reach the monitor"
  }

  assert {
    condition     = tonumber(datadog_monitor.etcd_database_usage_high[0].monitor_thresholds[0].critical) == 95
    error_message = "the critical threshold must reach the monitor"
  }

  assert {
    condition     = can(regex("> 20", datadog_monitor.pods_pending[0].query))
    error_message = "the pods_pending critical threshold must reach its query"
  }
}

# The disk threshold is deliberately lower than CPU and memory because the
# kubelet evicts under disk pressure well before 90 percent.
run "disk_threshold_is_lower_than_cpu_and_memory" {
  command = plan

  assert {
    condition = (
      tonumber(datadog_monitor.node_disk_high[0].monitor_thresholds[0].critical) <
      tonumber(datadog_monitor.node_cpu_high[0].monitor_thresholds[0].critical)
    )
    error_message = "node_disk_high must default to a lower critical threshold than node_cpu_high"
  }

  assert {
    condition = (
      tonumber(datadog_monitor.etcd_database_usage_high[0].monitor_thresholds[0].warning) <
      tonumber(datadog_monitor.node_cpu_high[0].monitor_thresholds[0].warning)
    )
    error_message = "etcd_database_usage_high must warn earlier than the saturation monitors, since recovery means deleting objects"
  }
}

run "tags_compose_base_common_and_additional" {
  command = plan

  variables {
    additional_tags = ["extra:tag"]
    env             = "prod"
  }

  assert {
    condition     = contains(datadog_monitor.node_cpu_high[0].tags, "resource:aks")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.node_cpu_high[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.node_cpu_high[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
