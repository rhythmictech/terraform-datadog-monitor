########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:functions"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# HTTP 5xx rate
########################################
variable "http_5xx_rate_enabled" {
  default     = true
  description = "Enable Function App HTTP 5xx rate monitor"
  type        = bool
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
  description = "Whether to use the query alert base message for Function App HTTP 5xx rate monitor"
  type        = bool
}

########################################
# Response time
########################################
variable "response_time_enabled" {
  default     = true
  description = "Enable Function App response time monitor"
  type        = bool
}

variable "response_time_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "response_time_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "response_time_threshold_critical" {
  default     = 5
  description = "Average response time in seconds at which to alert critical"
  type        = number
}

variable "response_time_threshold_warning" {
  default     = 2
  description = "Average response time in seconds at which to alert warning"
  type        = number
}

variable "response_time_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Function App response time monitor"
  type        = bool
}

########################################
# Execution stall
########################################
variable "execution_stall_enabled" {
  default     = false
  description = "Enable Function App execution stall monitor (disabled by default; an idle function app is legitimate for event-driven workloads)"
  type        = bool
}

variable "execution_stall_evaluation_window" {
  default     = "last_1h"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "execution_stall_no_data_window" {
  default     = 60
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "execution_stall_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Function App execution stall monitor"
  type        = bool
}

########################################
# Memory working set
########################################
variable "memory_working_set_enabled" {
  default     = false
  description = "Enable Function App memory working set monitor (disabled by default; the meaningful threshold depends on the hosting plan)"
  type        = bool
}

variable "memory_working_set_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "memory_working_set_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "memory_working_set_threshold_critical" {
  default     = 1288490188
  description = "Average memory working set in bytes at which to alert critical (default is 1.2 GiB, 80 percent of the Consumption-plan 1.5 GiB cap)"
  type        = number
}

variable "memory_working_set_threshold_warning" {
  default     = 1073741824
  description = "Average memory working set in bytes at which to alert warning (default is 1 GiB)"
  type        = number
}

variable "memory_working_set_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Function App memory working set monitor"
  type        = bool
}

########################################
# Health check status
########################################
variable "health_check_status_enabled" {
  default     = false
  description = "Enable Function App health check monitor (disabled by default; requires a health-check path configured on the app)"
  type        = bool
}

variable "health_check_status_evaluation_window" {
  default     = "last_10m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "health_check_status_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "health_check_status_threshold_critical" {
  default     = 50
  description = "Percentage of healthy instances below which to alert critical"
  type        = number
}

variable "health_check_status_threshold_warning" {
  default     = 100
  description = "Percentage of healthy instances below which to alert warning"
  type        = number
}

variable "health_check_status_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Function App health check monitor"
  type        = bool
}
