########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:elasticache"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

variable "query_organize_by_fields" {
  default     = "cachenodeid,cacheclusterid,region,aws_account,env,datadog_managed"
  description = "Fields (in order) by which to organize the results of the monitor queries for this module. An example modification would be to add replication_group to the front of the default value."
}

########################################
# Node CPU Utilization
########################################
variable "cpu_utilization_enabled" {
  default     = true
  description = "Enable CPU utilization monitor"
  type        = bool
}

variable "cpu_utilization_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_utilization_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_utilization_threshold_critical" {
  default     = 90
  description = "Critical threshold (percent)"
  type        = number
}

variable "cpu_utilization_threshold_warning" {
  default     = 80
  description = "Warning threshold (percent)"
  type        = number
}

variable "cpu_utilization_use_message" {
  description = "Whether to use the query alert base message for CPU utilization monitor"
  type        = bool
  default     = true
}

########################################
# CPU Utilization (anomaly detection)
########################################
variable "cpu_utilization_anomaly_enabled" {
  default     = false
  description = "Enable CPU utilization anomaly monitor"
  type        = bool
}

variable "cpu_utilization_anomaly_evaluation_window" {
  default     = "last_1h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_utilization_anomaly_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_utilization_anomaly_deviations" {
  default     = 4
  description = "Standard deviations"
  type        = number
}

variable "cpu_utilization_anomaly_seasonality" {
  default     = "weekly"
  description = "Seasonaility (hourly, daily, weekly)"
  type        = string
}

variable "cpu_utilization_anomaly_rollup" {
  default     = 60
  description = "Rollup interval (must be sized based on evaluation window/span and seasonaility)"
  type        = number
}

variable "cpu_utilization_anomaly_recovery_window" {
  default     = "last_15m"
  description = "Recovery window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_utilization_anomaly_trigger_window" {
  default     = "last_1h"
  description = "Trigger window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_utilization_anomaly_threshold_critical" {
  default     = null
  description = "Critical threshold (percent)"
  type        = number
}

variable "cpu_utilization_anomaly_threshold_warning" {
  default     = null
  description = "Warning threshold (percent)"
  type        = number
}

variable "cpu_utilization_anomaly_use_message" {
  description = "Whether to use the query alert base message for CPU utilization anomaly monitor"
  type        = bool
  default     = false
}

########################################
# Elasticache Evictions
########################################
variable "evictions_enabled" {
  default     = false
  description = "Enable eviction rate monitor"
  type        = bool
}

variable "evictions_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "evictions_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "evictions_threshold_critical" {
  default     = null
  description = "Critical threshold (count)"
  type        = number
}

variable "evictions_threshold_warning" {
  default     = null
  description = "Warning threshold (count)"
  type        = number
}

variable "evictions_use_message" {
  description = "Whether to use the query alert base message for evictions monitor"
  type        = bool
  default     = false
}

########################################
# Cache hit rate
########################################
variable "hit_rate_enabled" {
  default     = false
  description = "Enable cache hit rate monitor"
  type        = bool
}

variable "hit_rate_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "hit_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "hit_rate_threshold_critical" {
  default     = null
  description = "Critical threshold (percentage)"
  type        = number
}

variable "hit_rate_threshold_warning" {
  default     = null
  description = "Warning threshold (percentage)"
  type        = number
}

variable "hit_rate_use_message" {
  description = "Whether to use the query alert base message for hit rate monitor"
  type        = bool
  default     = false
}

########################################
# Cache hit rate (anomaly detection)
########################################
variable "hit_rate_anomaly_enabled" {
  default     = false
  description = "Enable cache hit rate anomaly monitor"
  type        = bool
}

variable "hit_rate_anomaly_evaluation_window" {
  default     = "last_1h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "hit_rate_anomaly_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "hit_rate_anomaly_deviations" {
  default     = 2
  description = "Standard deviations"
  type        = number
}

variable "hit_rate_anomaly_seasonality" {
  default     = "daily"
  description = "Seasonaility (hourly, daily, weekly)"
  type        = string
}

variable "hit_rate_anomaly_threshold_critical" {
  default     = null
  description = "Critical threshold (percentage)"
  type        = number
}

variable "hit_rate_anomaly_use_message" {
  description = "Whether to use the query alert base message for hit rate anomaly monitor"
  type        = bool
  default     = false
}

########################################
# Max Connections
########################################
variable "max_connections_enabled" {
  default     = false
  description = "Enable max connections monitor"
  type        = bool
}

variable "max_connections_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "max_connections_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "max_connections_threshold_critical" {
  default     = 64000
  description = "Critical threshold (connections)"
  type        = number
}

variable "max_connections_threshold_warning" {
  default     = 60000
  description = "Warning threshold (connections)"
  type        = number
}

variable "max_connections_use_message" {
  description = "Whether to use the query alert base message for max connections monitor"
  type        = bool
  default     = false
}

########################################
# Swap usage (by node)
########################################
variable "swap_usage_enabled" {
  default     = false
  description = "Enable swap usage monitor"
  type        = bool
}

variable "swap_usage_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "swap_usage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "swap_usage_threshold_critical" {
  default     = 52428800 # Redis recommended liit
  description = "Critical threshold (bytes)"
  type        = number
}

variable "swap_usage_threshold_warning" {
  default     = null
  description = "Warning threshold (bytes)"
  type        = number
}

variable "swap_usage_use_message" {
  description = "Whether to use the query alert base message for swap usage monitor"
  type        = bool
  default     = false
}

########################################
# Memory Utilization
########################################
variable "memory_utilization_enabled" {
  default     = true
  description = "Enable memory utilization monitor"
  type        = bool
}

variable "memory_utilization_evaluation_window" {
  default     = "last_1h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`)"
  type        = string
}

variable "memory_utilization_no_data_window" {
  default     = 15
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "memory_utilization_threshold_critical" {
  default     = 80
  description = "Critical threshold (percentage)"
  type        = number
}

variable "memory_utilization_threshold_warning" {
  default     = 70
  description = "Warning threshold (percentage)"
  type        = number
}

variable "memory_utilization_use_message" {
  description = "Whether to use the query alert base message for memory utilization monitor"
  type        = bool
  default     = true
}
