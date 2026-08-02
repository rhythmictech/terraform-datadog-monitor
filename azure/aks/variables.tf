########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:aks"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Node CPU utilization
########################################
variable "node_cpu_high_enabled" {
  default     = true
  description = "Enable AKS node CPU utilization monitor"
  type        = bool
}

variable "node_cpu_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "node_cpu_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "node_cpu_high_threshold_critical" {
  default     = 90
  description = "Aggregated node CPU utilization percentage at which to alert critical"
  type        = number
}

variable "node_cpu_high_threshold_warning" {
  default     = 80
  description = "Aggregated node CPU utilization percentage at which to alert warning"
  type        = number
}

variable "node_cpu_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS node CPU utilization monitor"
  type        = bool
}

########################################
# Node memory working set
########################################
variable "node_memory_working_set_high_enabled" {
  default     = true
  description = "Enable AKS node memory working set monitor. Working set rather than RSS because the kubelet evicts pods based on working set memory"
  type        = bool
}

variable "node_memory_working_set_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "node_memory_working_set_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "node_memory_working_set_high_threshold_critical" {
  default     = 90
  description = "Node memory working set percentage at which to alert critical"
  type        = number
}

variable "node_memory_working_set_high_threshold_warning" {
  default     = 80
  description = "Node memory working set percentage at which to alert warning"
  type        = number
}

variable "node_memory_working_set_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS node memory working set monitor"
  type        = bool
}

########################################
# Node disk usage
########################################
variable "node_disk_high_enabled" {
  default     = true
  description = "Enable AKS node disk usage monitor"
  type        = bool
}

variable "node_disk_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "node_disk_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "node_disk_high_threshold_critical" {
  default     = 85
  description = "Node disk usage percentage at which to alert critical. Lower than the CPU and memory defaults on purpose: the kubelet begins evicting pods under disk pressure and can stop reporting entirely on a full disk, so 90 would be too late"
  type        = number
}

variable "node_disk_high_threshold_warning" {
  default     = 75
  description = "Node disk usage percentage at which to alert warning"
  type        = number
}

variable "node_disk_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS node disk usage monitor"
  type        = bool
}

########################################
# API server CPU utilization
########################################
variable "apiserver_cpu_high_enabled" {
  default     = true
  description = "Enable AKS API server CPU utilization monitor. A throttled API server stalls every controller in the cluster"
  type        = bool
}

variable "apiserver_cpu_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "apiserver_cpu_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "apiserver_cpu_high_threshold_critical" {
  default     = 90
  description = "API server CPU utilization percentage (against its current limit) at which to alert critical"
  type        = number
}

variable "apiserver_cpu_high_threshold_warning" {
  default     = 80
  description = "API server CPU utilization percentage at which to alert warning"
  type        = number
}

variable "apiserver_cpu_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS API server CPU utilization monitor"
  type        = bool
}

########################################
# API server memory utilization
########################################
variable "apiserver_memory_high_enabled" {
  default     = true
  description = "Enable AKS API server memory utilization monitor"
  type        = bool
}

variable "apiserver_memory_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "apiserver_memory_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "apiserver_memory_high_threshold_critical" {
  default     = 90
  description = "API server memory utilization percentage (against its current limit) at which to alert critical"
  type        = number
}

variable "apiserver_memory_high_threshold_warning" {
  default     = 80
  description = "API server memory utilization percentage at which to alert warning"
  type        = number
}

variable "apiserver_memory_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS API server memory utilization monitor"
  type        = bool
}

########################################
# etcd database usage
########################################
variable "etcd_database_usage_high_enabled" {
  default     = true
  description = "Enable AKS etcd database usage monitor. The highest-value monitor in this module: etcd database usage is driven by the client's own object count and size, and at quota the cluster goes read-only"
  type        = bool
}

variable "etcd_database_usage_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "etcd_database_usage_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "etcd_database_usage_high_threshold_critical" {
  default     = 90
  description = "etcd database usage percentage at which to alert critical"
  type        = number
}

variable "etcd_database_usage_high_threshold_warning" {
  default     = 75
  description = "etcd database usage percentage at which to alert warning. Deliberately well below the critical threshold: recovering from a full etcd means deleting objects, which takes time to organize"
  type        = number
}

variable "etcd_database_usage_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS etcd database usage monitor"
  type        = bool
}

########################################
# Failed pods
#
# Depends on an unconfirmed dimension tag pair. See README.
########################################
variable "pods_failed_enabled" {
  default     = true
  description = "Enable AKS failed pods monitor. NOTE: `kube_pod_status_phase` reports every phase under one metric name discriminated by a dimension, so this query depends on the Datadog tag key AND value for that dimension. Neither is confirmed against live data. If either is wrong the query silently returns nothing"
  type        = bool
}

variable "pods_failed_phase_tag_key" {
  default     = "phase"
  description = "Datadog tag key carrying the pod phase. Azure names the dimension `phase`; this is the expected Datadog key but has NOT been confirmed against live data. Exposed as a variable so it can be corrected without a module change"
  type        = string
}

variable "pods_failed_phase_tag_value" {
  default     = "Failed"
  description = "Datadog tag value identifying the failed pod phase. Kubernetes capitalises phase names (`Failed`), but Datadog normalises tag values to lowercase in some integrations. Whether it does here is NOT confirmed; set to `failed` if the capitalised form returns no data"
  type        = string
}

variable "pods_failed_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "pods_failed_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "pods_failed_threshold_critical" {
  default     = 0
  description = "Number of failed pods at which to alert critical. Defaults to 0 so that any failed pod alerts, since the query compares with `>`"
  type        = number
}

variable "pods_failed_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS failed pods monitor"
  type        = bool
}

########################################
# Pending pods
#
# Depends on an unconfirmed dimension tag pair. See README.
########################################
variable "pods_pending_enabled" {
  default     = true
  description = "Enable AKS pending pods monitor. Same unconfirmed-dimension caveat as `pods_failed_enabled`"
  type        = bool
}

variable "pods_pending_phase_tag_key" {
  default     = "phase"
  description = "Datadog tag key carrying the pod phase. Not confirmed against live data; see `pods_failed_phase_tag_key`"
  type        = string
}

variable "pods_pending_phase_tag_value" {
  default     = "Pending"
  description = "Datadog tag value identifying the pending pod phase. Not confirmed against live data; set to `pending` if the capitalised form returns no data"
  type        = string
}

variable "pods_pending_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor. Longer than the module default on purpose: pods sit in Pending routinely while images pull and volumes attach, so a short window alerts on healthy scheduling churn. What matters is pods staying pending"
  type        = string
}

variable "pods_pending_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "pods_pending_threshold_critical" {
  default     = 5
  description = "Number of pending pods at which to alert critical. A guess tuned for a generic cluster; confirm against real scheduling churn"
  type        = number
}

variable "pods_pending_threshold_warning" {
  default     = 1
  description = "Number of pending pods at which to alert warning"
  type        = number
}

variable "pods_pending_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS pending pods monitor"
  type        = bool
}

########################################
# Nodes not ready
#
# Depends on TWO unconfirmed dimension tag pairs. See README.
########################################
variable "nodes_not_ready_enabled" {
  default     = true
  description = "Enable AKS nodes-not-ready monitor. NOTE: this is the most fragile monitor in the module, depending on TWO unconfirmed dimension tag pairs (condition and status). Confirm both against live data"
  type        = bool
}

variable "nodes_not_ready_condition_tag_key" {
  default     = "condition"
  description = "Datadog tag key carrying the node condition type. Azure names the dimension `condition`; NOT confirmed against live data"
  type        = string
}

variable "nodes_not_ready_condition_tag_value" {
  default     = "Ready"
  description = "Datadog tag value identifying the Ready node condition. Kubernetes capitalises condition names; set to `ready` if the capitalised form returns no data"
  type        = string
}

variable "nodes_not_ready_status_tag_key" {
  default     = "status"
  description = "Datadog tag key carrying the node condition status. Azure names the dimension `status`; NOT confirmed against live data"
  type        = string
}

variable "nodes_not_ready_status_tag_value" {
  default     = "false"
  description = "Datadog tag value identifying a condition that is NOT met. Combined with the condition key this selects nodes whose Ready condition is false"
  type        = string
}

variable "nodes_not_ready_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "nodes_not_ready_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "nodes_not_ready_threshold_critical" {
  default     = 0
  description = "Number of not-ready nodes at which to alert critical. Defaults to 0 so that any not-ready node alerts, since the query compares with `>`"
  type        = number
}

variable "nodes_not_ready_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS nodes-not-ready monitor"
  type        = bool
}

########################################
# Unschedulable pods (cluster autoscaler)
########################################
variable "unschedulable_pods_enabled" {
  default     = false
  description = "Enable AKS unschedulable pods monitor. Disabled by default: the `cluster_autoscaler_*` metrics are only emitted when the cluster autoscaler is enabled on the cluster"
  type        = bool
}

variable "unschedulable_pods_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "unschedulable_pods_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "unschedulable_pods_threshold_critical" {
  default     = 0
  description = "Number of unschedulable pods at which to alert critical. Defaults to 0 so that any unschedulable pod alerts, since the query compares with `>`"
  type        = number
}

variable "unschedulable_pods_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS unschedulable pods monitor"
  type        = bool
}

########################################
# Cluster autoscaler health
########################################
variable "autoscaler_unhealthy_enabled" {
  default     = false
  description = "Enable AKS cluster autoscaler health monitor. Disabled by default: same cluster-autoscaler feature gate as `unschedulable_pods_enabled`"
  type        = bool
}

variable "autoscaler_unhealthy_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "autoscaler_unhealthy_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "autoscaler_unhealthy_threshold_critical" {
  default     = 1
  description = "Value below which to alert critical. The metric reports 1 when the autoscaler considers the cluster safe to act on, so the query compares with `<`"
  type        = number
}

variable "autoscaler_unhealthy_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS cluster autoscaler health monitor"
  type        = bool
}

########################################
# etcd CPU utilization
########################################
variable "etcd_cpu_high_enabled" {
  default     = false
  description = "Enable AKS etcd CPU utilization monitor. Disabled by default, and not because of a feature gate: Azure operates and scales the AKS control plane, so etcd CPU is not customer-actionable the way etcd database usage is"
  type        = bool
}

variable "etcd_cpu_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "etcd_cpu_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "etcd_cpu_high_threshold_critical" {
  default     = 90
  description = "etcd CPU utilization percentage (against its current limit) at which to alert critical"
  type        = number
}

variable "etcd_cpu_high_threshold_warning" {
  default     = 80
  description = "etcd CPU utilization percentage at which to alert warning"
  type        = number
}

variable "etcd_cpu_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for AKS etcd CPU utilization monitor"
  type        = bool
}
