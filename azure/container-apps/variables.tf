########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:container-apps"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Replica restarts
########################################
variable "restart_count_high_enabled" {
  default     = true
  description = "Enable Container App replica restart monitor. The metric is cumulative per replica, so the query wraps it in `monotonic_diff()` to alert on the per-interval increase rather than the lifetime total"
  type        = bool
}

variable "restart_count_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "restart_count_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "restart_count_high_threshold_critical" {
  default     = 5
  description = "Replica restarts within the evaluation window at which to alert critical"
  type        = number
}

variable "restart_count_high_threshold_warning" {
  default     = 1
  description = "Replica restarts within the evaluation window at which to alert warning"
  type        = number
}

variable "restart_count_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App replica restart monitor"
  type        = bool
}

########################################
# Running replicas
########################################
variable "replicas_low_enabled" {
  default     = true
  description = "Enable Container App running replica monitor"
  type        = bool
}

variable "replicas_low_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "replicas_low_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "replicas_low_threshold_critical" {
  default     = 1
  description = "Running replica count below which to alert critical. The query compares with `<`, so 1 means alert when no replica is running. Apps with a scale-to-zero rule should disable this monitor rather than lower the threshold"
  type        = number
}

variable "replicas_low_threshold_warning" {
  default     = 2
  description = "Running replica count below which to alert warning. Above the critical threshold, since this monitor compares with `<`"
  type        = number
}

variable "replicas_low_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App running replica monitor"
  type        = bool
}

########################################
# CPU utilization
########################################
variable "cpu_high_enabled" {
  default     = true
  description = "Enable Container App CPU utilization monitor. Azure labels this metric Preview"
  type        = bool
}

variable "cpu_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_high_threshold_critical" {
  default     = 90
  description = "CPU utilization percentage (against the container's CPU limit) at which to alert critical"
  type        = number
}

variable "cpu_high_threshold_warning" {
  default     = 80
  description = "CPU utilization percentage at which to alert warning"
  type        = number
}

variable "cpu_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App CPU utilization monitor"
  type        = bool
}

########################################
# Memory utilization
########################################
variable "memory_high_enabled" {
  default     = true
  description = "Enable Container App memory utilization monitor. Azure labels this metric Preview"
  type        = bool
}

variable "memory_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "memory_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "memory_high_threshold_critical" {
  default     = 90
  description = "Memory utilization percentage (against the container's memory limit) at which to alert critical"
  type        = number
}

variable "memory_high_threshold_warning" {
  default     = 80
  description = "Memory utilization percentage at which to alert warning"
  type        = number
}

variable "memory_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App memory utilization monitor"
  type        = bool
}

########################################
# Response time
########################################
variable "response_time_high_enabled" {
  default     = true
  description = "Enable Container App response time monitor. Azure labels this metric Preview"
  type        = bool
}

variable "response_time_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "response_time_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "response_time_high_threshold_critical" {
  default     = 2000
  description = "Average response time in MILLISECONDS at which to alert critical. Note the unit: unlike azure/app-service and azure/functions, where `average_response_time` is in seconds, this metric is milliseconds"
  type        = number
}

variable "response_time_high_threshold_warning" {
  default     = 1000
  description = "Average response time in MILLISECONDS at which to alert warning"
  type        = number
}

variable "response_time_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App response time monitor"
  type        = bool
}

########################################
# 5xx rate
#
# Depends on an unconfirmed dimension tag pair. See README.
########################################
variable "http_5xx_rate_enabled" {
  default     = true
  description = "Enable Container App 5xx rate monitor. NOTE: `requests` reports all status classes under one metric name discriminated by a dimension, so this query depends on the Datadog tag key AND value for that dimension. Azure names the dimension `statusCodeCategory`, in camelCase, so the assumed lowercase key carries the highest tag-spelling risk in this module. If either is wrong the query silently returns nothing"
  type        = bool
}

variable "http_5xx_rate_status_tag_key" {
  default     = "statuscodecategory"
  description = "Datadog tag key carrying the HTTP status class. Azure names the dimension `statusCodeCategory`; the lowercased form here is the expected Datadog key but has NOT been confirmed against live data. Exposed as a variable so it can be corrected without a module change"
  type        = string
}

variable "http_5xx_rate_status_tag_value" {
  default     = "5xx"
  description = "Datadog tag value identifying the server-error status class. NOT confirmed against live data"
  type        = string
}

variable "http_5xx_rate_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "http_5xx_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "http_5xx_rate_threshold_critical" {
  default     = 5
  description = "Percentage of requests returning 5xx at which to alert critical"
  type        = number
}

variable "http_5xx_rate_threshold_warning" {
  default     = 1
  description = "Percentage of requests returning 5xx at which to alert warning"
  type        = number
}

variable "http_5xx_rate_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App 5xx rate monitor"
  type        = bool
}

########################################
# Cold starts (requires the Datadog Serverless Agent)
########################################
variable "cold_start_high_enabled" {
  default     = false
  description = "Enable Container App cold start monitor. Disabled by default: this is the only metric in this module that requires the Datadog Serverless Agent deployed inside the container app (sidecar or in-container). It also lives in the `azure.containerapps.enhanced.*` namespace, with no `app_` infix, unlike every other metric here"
  type        = bool
}

variable "cold_start_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cold_start_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cold_start_high_threshold_critical" {
  default     = 10
  description = "Cold starts within the evaluation window at which to alert critical"
  type        = number
}

variable "cold_start_high_threshold_warning" {
  default     = 1
  description = "Cold starts within the evaluation window at which to alert warning"
  type        = number
}

variable "cold_start_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App cold start monitor"
  type        = bool
}

########################################
# Resiliency: request timeouts
########################################
variable "resiliency_request_timeouts_enabled" {
  default     = false
  description = "Enable Container App request timeout monitor. Disabled by default: the resiliency metric family is only emitted when a resiliency policy is configured on the app"
  type        = bool
}

variable "resiliency_request_timeouts_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "resiliency_request_timeouts_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "resiliency_request_timeouts_threshold_critical" {
  default     = 10
  description = "Request timeouts within the evaluation window at which to alert critical"
  type        = number
}

variable "resiliency_request_timeouts_threshold_warning" {
  default     = 1
  description = "Request timeouts within the evaluation window at which to alert warning"
  type        = number
}

variable "resiliency_request_timeouts_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App request timeout monitor"
  type        = bool
}

########################################
# Resiliency: ejected hosts
########################################
variable "resiliency_ejected_hosts_enabled" {
  default     = false
  description = "Enable Container App ejected host monitor. Disabled by default: same resiliency-policy feature gate as `resiliency_request_timeouts_enabled`"
  type        = bool
}

variable "resiliency_ejected_hosts_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "resiliency_ejected_hosts_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "resiliency_ejected_hosts_threshold_critical" {
  default     = 0
  description = "Number of ejected hosts at which to alert critical. Defaults to 0 so that any ejected host alerts, since the query compares with `>`"
  type        = number
}

variable "resiliency_ejected_hosts_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App ejected host monitor"
  type        = bool
}

########################################
# GPU utilization
########################################
variable "gpu_utilization_high_enabled" {
  default     = false
  description = "Enable Container App GPU utilization monitor. Disabled by default: GPU workloads only. Azure labels this metric Preview"
  type        = bool
}

variable "gpu_utilization_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "gpu_utilization_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "gpu_utilization_high_threshold_critical" {
  default     = 90
  description = "GPU utilization percentage at which to alert critical"
  type        = number
}

variable "gpu_utilization_high_threshold_warning" {
  default     = 80
  description = "GPU utilization percentage at which to alert warning"
  type        = number
}

variable "gpu_utilization_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Container App GPU utilization monitor"
  type        = bool
}
