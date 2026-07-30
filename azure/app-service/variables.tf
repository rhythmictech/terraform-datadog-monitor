########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:app-service"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# HTTP 5xx rate
########################################
variable "http_5xx_rate_enabled" {
  default     = true
  description = "Enable App Service HTTP 5xx rate monitor"
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
  description = "Whether to use the query alert base message for App Service HTTP 5xx rate monitor"
  type        = bool
}

########################################
# Response time
########################################
variable "response_time_enabled" {
  default     = true
  description = "Enable App Service response time monitor"
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
  description = "Whether to use the query alert base message for App Service response time monitor"
  type        = bool
}

########################################
# HTTP 4xx rate
########################################
variable "http_4xx_rate_enabled" {
  default     = false
  description = "Enable App Service HTTP 4xx rate monitor (disabled by default; 4xx on a public app is largely client-driven)"
  type        = bool
}

variable "http_4xx_rate_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "http_4xx_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "http_4xx_rate_threshold_critical" {
  default     = 25
  description = "Percentage of requests returning 4xx at which to alert critical"
  type        = number
}

variable "http_4xx_rate_threshold_warning" {
  default     = 10
  description = "Percentage of requests returning 4xx at which to alert warning"
  type        = number
}

variable "http_4xx_rate_use_message" {
  default     = false
  description = "Whether to use the query alert base message for App Service HTTP 4xx rate monitor"
  type        = bool
}

########################################
# Health check status
########################################
variable "health_check_status_enabled" {
  default     = false
  description = "Enable App Service health check monitor (disabled by default; requires a health-check path configured on the app)"
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
  description = "Whether to use the query alert base message for App Service health check monitor"
  type        = bool
}

########################################
# Filesystem quota usage
########################################
variable "file_system_usage_enabled" {
  default     = false
  description = "Enable App Service filesystem quota monitor (disabled by default; Datadog documents the unit as byte while the description says percentage, so confirm against live data first)"
  type        = bool
}

variable "file_system_usage_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "file_system_usage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "file_system_usage_threshold_critical" {
  default     = 90
  description = "Filesystem quota consumption at which to alert critical (confirm the metric unit before relying on this)"
  type        = number
}

variable "file_system_usage_threshold_warning" {
  default     = 80
  description = "Filesystem quota consumption at which to alert warning (confirm the metric unit before relying on this)"
  type        = number
}

variable "file_system_usage_use_message" {
  default     = false
  description = "Whether to use the query alert base message for App Service filesystem quota monitor"
  type        = bool
}
