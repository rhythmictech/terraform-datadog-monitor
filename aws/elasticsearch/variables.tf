########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:elasticsearch"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# ElasticSearch cluster health (red)
########################################
variable "cluster_health_red_enabled" {
  default     = false
  description = "Enable cluster health_red monitor"
  type        = bool
}

variable "cluster_health_red_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cluster_health_red_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

#######################################
# ElasticSearch cluster health (yellow)
########################################
variable "cluster_health_yellow_enabled" {
  default     = false
  description = "Enable cluster health monitor"
  type        = bool
}

variable "cluster_health_yellow_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cluster_health_yellow_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

########################################
# Node CPU Utilization
########################################
variable "cpu_utilization_enabled" {
  default     = false
  description = "Enable CPU utilization monitor"
  type        = bool
}

variable "cpu_utilization_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_utilization_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_utilization_threshold_critical" {
  default     = 0.90
  description = "Critical threshold (percent)"
  type        = number
}

variable "cpu_utilization_threshold_warning" {
  default     = 0.80
  description = "Warning threshold (percent)"
  type        = number
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

variable "cpu_utilization_anomaly_rollup" {
  default     = 60
  description = "Rollup interval (must be sized based on evaluation window/span and seasonaility)"
  type        = number
}

variable "cpu_utilization_anomaly_seasonality" {
  default     = "weekly"
  description = "Seasonaility (hourly, daily, weekly)"
  type        = string
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

########################################
# ElasticSearch cluster free storage
########################################
variable "free_storage_enabled" {
  default     = true
  description = "Enable free storage monitor"
  type        = bool
}

variable "free_storage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "free_storage_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "free_storage_threshold_critical" {
  default     = null
  description = "Critical threshold (GB)"
  type        = number
}

variable "free_storage_threshold_warning" {
  default     = null
  description = "Warning threshold (GB)"
  type        = number
}
