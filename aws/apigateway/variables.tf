########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:apigateway"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# HTTP 5xx Response Codes
########################################
variable "http_5xx_responses_enabled" {
  default     = false
  description = "Enable HTTP 5xx response monitor"
  type        = bool
}

variable "http_5xx_responses_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "http_5xx_responses_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "http_5xx_responses_threshold_critical" {
  default     = 0.75
  description = "Critical threshold (percentage, 0-100)"
  type        = number
}

variable "http_5xx_responses_threshold_warning" {
  default     = 0.25
  description = "Warning threshold (percentage, 0-100)"
  type        = number
}

########################################
# Latency Instances
########################################
variable "latency_enabled" {
  default     = false
  description = "Enable latency monitor"
  type        = bool
}

variable "latency_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "latency_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "latency_threshold_critical" {
  default     = null
  description = "Critical threshold (seconds)"
  type        = number
}

variable "latency_threshold_warning" {
  default     = null
  description = "Warning threshold (seconds)"
  type        = number
}
