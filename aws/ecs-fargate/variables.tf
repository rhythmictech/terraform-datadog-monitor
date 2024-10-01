########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:ecs-fargate"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Fargate Agent Status
########################################
variable "fargate_check_enabled" {
  default     = true
  description = "Enable Fargate check monitor"
  type        = bool
}

variable "fargate_check_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "fargate_check_group_by" {
  default     = "*"
  description = "Tag to group alerts by (will result in multiple alerts being generated based on tag cardinality)"
  type        = string
}

variable "fargate_check_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "fargate_check_threshold_critical" {
  default     = 5
  description = "Critical threshold"
  type        = number
}

variable "fargate_check_threshold_warning" {
  default     = 3
  description = "Warning threshold"
  type        = number
}

########################################
# Fargate Task CPU Utilization
########################################
variable "cpu_utilization_enabled" {
  default     = false
  description = "Enable Fargate task CPU utilization monitor"
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
  description = "Enable cache hit rate anomaly monitor"
  type        = bool
}

variable "cpu_utilization_anomaly_evaluation_window" {
  default     = "last_1d"
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
# Fargate Task Memory Reservation
########################################
variable "memory_utilization_enabled" {
  default     = false
  description = "Enable Fargate task memory utilization monitor"
  type        = bool
}

variable "memory_utilization_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}
variable "memory_utilization_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "memory_utilization_threshold_critical" {
  default     = 90
  description = "Critical threshold (percent)"
  type        = number
}

variable "memory_utilization_threshold_warning" {
  default     = 80
  description = "Warning threshold (percent)"
  type        = number
}
