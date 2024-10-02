########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:rds"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Connection Rate (anomaly detection)
########################################
variable "connection_count_anomaly_enabled" {
  default     = true
  description = "Enable CPU utilization anomaly monitor"
  type        = bool
}

variable "connection_count_anomaly_evaluation_window" {
  default     = "last_1h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "connection_count_anomaly_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "connection_count_anomaly_deviations" {
  default     = 3
  description = "Standard deviations"
  type        = number
}

variable "connection_count_anomaly_rollup" {
  default     = 60
  description = "Rollup interval (must be sized based on evaluation window/span and seasonaility)"
  type        = number
}

variable "connection_count_anomaly_seasonality" {
  default     = "weekly"
  description = "Seasonaility (hourly, daily, weekly)"
  type        = string
}

variable "connection_count_anomaly_recovery_window" {
  default     = "last_15m"
  description = "Recovery window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "connection_count_anomaly_trigger_window" {
  default     = "last_1h"
  description = "Trigger window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "connection_count_anomaly_threshold_critical" {
  default     = 0.75
  description = "Critical threshold (percent)"
  type        = number
}

variable "connection_count_anomaly_threshold_warning" {
  default     = null
  description = "Warning threshold (percent)"
  type        = number
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
  default     = "last_5m"
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
# ElasticSearch cluster used storage
########################################
variable "used_storage_enabled" {
  default     = true
  description = "Enable used storage monitor"
  type        = bool
}

variable "used_storage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "used_storage_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "used_storage_threshold_critical" {
  default     = 90
  description = "Critical threshold (percentage, 0-100)"
  type        = number
}

variable "used_storage_threshold_warning" {
  default     = 80
  description = "Warning threshold (percentage, 0-100)"
  type        = number
}
