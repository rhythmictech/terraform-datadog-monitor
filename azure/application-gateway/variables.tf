########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:application-gateway"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Unhealthy backend hosts
########################################
variable "unhealthy_hosts_enabled" {
  default     = true
  description = "Enable Application Gateway unhealthy backend host monitor"
  type        = bool
}

variable "unhealthy_hosts_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "unhealthy_hosts_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "unhealthy_hosts_threshold_critical" {
  default     = 0
  description = "Number of unhealthy backend hosts at which to alert critical. Defaults to 0 so that any unhealthy backend alerts, since the query compares with `>`"
  type        = number
}

variable "unhealthy_hosts_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Application Gateway unhealthy backend host monitor"
  type        = bool
}

########################################
# Healthy backend hosts
########################################
variable "healthy_hosts_low_enabled" {
  default     = true
  description = "Enable Application Gateway healthy backend host monitor"
  type        = bool
}

variable "healthy_hosts_low_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "healthy_hosts_low_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "healthy_hosts_low_threshold_critical" {
  default     = 1
  description = "Alert critical when the healthy backend host count falls below this value"
  type        = number
}

variable "healthy_hosts_low_threshold_warning" {
  default     = 2
  description = "Alert warning when the healthy backend host count falls below this value. Above the critical threshold because this monitor alerts on a value being too low"
  type        = number
}

variable "healthy_hosts_low_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Application Gateway healthy backend host monitor"
  type        = bool
}

########################################
# Failed requests
########################################
variable "failed_requests_enabled" {
  default     = true
  description = "Enable Application Gateway failed request monitor. This is the enabled-by-default error signal because it needs no status-group dimension filter, unlike `backend_5xx_rate`"
  type        = bool
}

variable "failed_requests_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "failed_requests_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "failed_requests_threshold_critical" {
  default     = 10
  description = "Number of failed requests in the evaluation window at which to alert critical"
  type        = number
}

variable "failed_requests_threshold_warning" {
  default     = 1
  description = "Number of failed requests in the evaluation window at which to alert warning"
  type        = number
}

variable "failed_requests_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Application Gateway failed request monitor"
  type        = bool
}

########################################
# Backend 5xx rate (disabled by default, unconfirmed dimension tag)
########################################
variable "backend_5xx_rate_enabled" {
  default     = false
  description = "Enable Application Gateway backend 5xx rate monitor. Disabled by default: `backend_response_status` reports all status classes under one metric name discriminated by a dimension, so this query depends on the Datadog tag key for that dimension (see `backend_5xx_rate_status_tag`). Confirm that key against live data before enabling, otherwise the query silently returns nothing. Also note the metric is V2 SKU only"
  type        = bool
}

variable "backend_5xx_rate_status_tag" {
  default     = "httpstatusgroup"
  description = "Datadog tag key carrying the Application Gateway backend response status group. Azure names the dimension `HttpStatusGroup`; the lowercased form here is the expected Datadog key but has NOT been confirmed against live data. Exposed as a variable so it can be corrected without a module change"
  type        = string
}

variable "backend_5xx_rate_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "backend_5xx_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "backend_5xx_rate_threshold_critical" {
  default     = 5
  description = "Backend 5xx percentage of total requests at which to alert critical"
  type        = number
}

variable "backend_5xx_rate_threshold_warning" {
  default     = 1
  description = "Backend 5xx percentage of total requests at which to alert warning"
  type        = number
}

variable "backend_5xx_rate_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Application Gateway backend 5xx rate monitor"
  type        = bool
}

########################################
# Backend latency (disabled by default, V2 SKU only)
########################################
variable "backend_latency_enabled" {
  default     = false
  description = "Enable Application Gateway backend latency monitor. Disabled by default: `backend_connect_time` is available only on the V2 SKU, so a V1 gateway reports nothing and the monitor would sit in no-data"
  type        = bool
}

variable "backend_latency_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "backend_latency_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "backend_latency_threshold_critical" {
  default     = 1000
  description = "Backend connect time in milliseconds at which to alert critical"
  type        = number
}

variable "backend_latency_threshold_warning" {
  default     = 500
  description = "Backend connect time in milliseconds at which to alert warning"
  type        = number
}

variable "backend_latency_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Application Gateway backend latency monitor"
  type        = bool
}

########################################
# Capacity units (disabled by default, V2 SKU only)
########################################
variable "capacity_units_high_enabled" {
  default     = false
  description = "Enable Application Gateway capacity unit monitor. Disabled by default: `capacity_units` is available only on the V2 SKU, and the meaningful ceiling depends on the gateway's configured maximum instance count, so the threshold must be set per gateway"
  type        = bool
}

variable "capacity_units_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "capacity_units_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "capacity_units_high_threshold_critical" {
  default     = 90
  description = "Consumed capacity units at which to alert critical. Set relative to the gateway's configured maximum instance count"
  type        = number
}

variable "capacity_units_high_threshold_warning" {
  default     = 80
  description = "Consumed capacity units at which to alert warning"
  type        = number
}

variable "capacity_units_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Application Gateway capacity unit monitor"
  type        = bool
}

########################################
# Gateway CPU (disabled by default, V1 SKU only)
########################################
variable "cpu_utilization_high_enabled" {
  default     = false
  description = "Enable Application Gateway CPU utilization monitor. Disabled by default: `cpu_utilization` is available only on the V1 SKU, which Azure has retired for new deployments. V2 gateways should use `capacity_units_high_enabled` instead"
  type        = bool
}

variable "cpu_utilization_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_utilization_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_utilization_high_threshold_critical" {
  default     = 90
  description = "Gateway CPU utilization percentage at which to alert critical"
  type        = number
}

variable "cpu_utilization_high_threshold_warning" {
  default     = 80
  description = "Gateway CPU utilization percentage at which to alert warning"
  type        = number
}

variable "cpu_utilization_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Application Gateway CPU utilization monitor"
  type        = bool
}
