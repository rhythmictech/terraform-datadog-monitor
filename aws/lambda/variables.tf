########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:lambda"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Lambda error rate
########################################
variable "error_rate_enabled" {
  default     = false
  description = "Enable Lambda error rate monitor"
  type        = bool
}

variable "error_rate_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "error_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "error_rate_threshold_critical" {
  default     = 75
  description = "Critical threshold (percentage, 0-100)"
  type        = number
}

variable "error_rate_threshold_warning" {
  default     = 25
  description = "Warning threshold (percentage, 0-100)"
  type        = number
}

########################################
# Lambda timeouts
########################################
variable "timeouts_enabled" {
  default     = false
  description = "Enable timeout count monitor"
  type        = bool
}

variable "timeouts_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "timeouts_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "timeouts_threshold_critical" {
  default     = 75
  description = "Critical threshold (count)"
  type        = number
}

variable "timeouts_threshold_warning" {
  default     = 25
  description = "Warning threshold (count)"
  type        = number
}

########################################
# Cold start monitor
########################################
variable "cold_starts_enabled" {
  default     = false
  description = "Enable cold starts monitor (requires enhanced metrics)"
  type        = bool
}

variable "cold_starts_evaluation_window" {
  default     = "last_4h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cold_starts_no_data_window" {
  default     = null
  description = "No data threshold (in minutes, null to disable)"
  type        = number
}

variable "cold_starts_threshold_critical" {
  default     = null
  description = "Critical threshold (count)"
  type        = number
}

variable "cold_starts_threshold_warning" {
  default     = null
  description = "Warning threshold (count)"
  type        = number
}

########################################
# OOM monitor
########################################
variable "out_of_memory_enabled" {
  default     = false
  description = "Enable out of memory monitor (requires enhanced metrics)"
  type        = bool
}

variable "out_of_memory_evaluation_window" {
  default     = "last_4h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "out_of_memory_no_data_window" {
  default     = null
  description = "No data threshold (in minutes, null to disable)"
  type        = number
}

variable "out_of_memory_threshold_critical" {
  default     = null
  description = "Critical threshold (count)"
  type        = number
}

variable "out_of_memory_threshold_warning" {
  default     = null
  description = "Warning threshold (count)"
  type        = number
}

########################################
# Iterator Age monitor
########################################
variable "iterator_age_enabled" {
  default     = false
  description = "Enable iterator age monitor"
  type        = bool
}

variable "iterator_age_evaluation_window" {
  default     = "last_1h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "iterator_age_no_data_window" {
  default     = null
  description = "No data threshold (in minutes, null to disable)"
  type        = number
}

variable "iterator_age_threshold_critical" {
  default     = 86400000
  description = "Critical threshold (milliseconds)"
  type        = number
}

variable "iterator_age_threshold_warning" {
  default     = null
  description = "Warning threshold (milliseconds)"
  type        = number
}

########################################
# Iterator Age forecast data loss
########################################
variable "iterator_age_forecast_enabled" {
  default     = false
  description = "Enable iterator age monitor"
  type        = bool
}

variable "iterator_age_forecast_evaluation_window" {
  default     = "last_1d"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "iterator_age_forecast_no_data_window" {
  default     = null
  description = "No data threshold (in minutes, null to disable)"
  type        = number
}

########################################
# Lambda throttle rate
########################################
variable "throttle_rate_enabled" {
  default     = false
  description = "Enable Lambda throttle rate monitor"
  type        = bool
}

variable "throttle_rate_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "throttle_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "throttle_rate_threshold_critical" {
  default     = 75
  description = "Critical threshold (percentage, 0-100)"
  type        = number
}

variable "throttle_rate_threshold_warning" {
  default     = 25
  description = "Warning threshold (percentage, 0-100)"
  type        = number
}
