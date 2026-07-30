########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:service-bus"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Dead-lettered messages
########################################
variable "dead_lettered_messages_enabled" {
  default     = true
  description = "Enable Service Bus dead-lettered message monitor"
  type        = bool
}

variable "dead_lettered_messages_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "dead_lettered_messages_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "dead_lettered_messages_threshold_critical" {
  default     = 10
  description = "Dead-lettered message count above which to alert critical (set to 0 for workloads where any dead letter means a lost job)"
  type        = number
}

variable "dead_lettered_messages_threshold_warning" {
  default     = 0
  description = "Dead-lettered message count above which to alert warning (the default of 0 warns on any dead letter)"
  type        = number
}

variable "dead_lettered_messages_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Service Bus dead-lettered message monitor"
  type        = bool
}

########################################
# Server errors
########################################
variable "server_errors_enabled" {
  default     = true
  description = "Enable Service Bus server error monitor"
  type        = bool
}

variable "server_errors_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "server_errors_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "server_errors_threshold_critical" {
  default     = 0
  description = "Server error count above which to alert critical (the default of 0 alerts on any server error in the evaluation window)"
  type        = number
}

variable "server_errors_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Service Bus server error monitor"
  type        = bool
}

########################################
# Throttled requests
########################################
variable "throttled_requests_enabled" {
  default     = true
  description = "Enable Service Bus throttled request monitor"
  type        = bool
}

variable "throttled_requests_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "throttled_requests_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "throttled_requests_threshold_critical" {
  default     = 10
  description = "Throttled request count at which to alert critical"
  type        = number
}

variable "throttled_requests_threshold_warning" {
  default     = 1
  description = "Throttled request count at which to alert warning"
  type        = number
}

variable "throttled_requests_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Service Bus throttled request monitor"
  type        = bool
}

########################################
# Active message backlog
########################################
variable "active_messages_backlog_enabled" {
  default     = true
  description = "Enable Service Bus active message backlog monitor"
  type        = bool
}

variable "active_messages_backlog_evaluation_window" {
  default     = "last_30m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "active_messages_backlog_no_data_window" {
  default     = 30
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "active_messages_backlog_threshold_critical" {
  default     = 1000
  description = "Active message count at which to alert critical (tune per workload)"
  type        = number
}

variable "active_messages_backlog_threshold_warning" {
  default     = 500
  description = "Active message count at which to alert warning (tune per workload)"
  type        = number
}

variable "active_messages_backlog_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Service Bus active message backlog monitor"
  type        = bool
}

########################################
# User errors
########################################
variable "user_errors_enabled" {
  default     = false
  description = "Enable Service Bus user error monitor (disabled by default; user errors are usually application-side and noisy)"
  type        = bool
}

variable "user_errors_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "user_errors_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "user_errors_threshold_critical" {
  default     = 100
  description = "User error count at which to alert critical"
  type        = number
}

variable "user_errors_threshold_warning" {
  default     = 25
  description = "User error count at which to alert warning"
  type        = number
}

variable "user_errors_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Service Bus user error monitor"
  type        = bool
}

########################################
# CPU (Premium SKU only)
########################################
variable "cpu_enabled" {
  default     = false
  description = "Enable Service Bus CPU monitor (disabled by default; emitted only by Premium SKU namespaces)"
  type        = bool
}

variable "cpu_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_threshold_critical" {
  default     = 90
  description = "Namespace CPU percentage at which to alert critical"
  type        = number
}

variable "cpu_threshold_warning" {
  default     = 80
  description = "Namespace CPU percentage at which to alert warning"
  type        = number
}

variable "cpu_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Service Bus CPU monitor"
  type        = bool
}

########################################
# Memory usage (Premium SKU only)
########################################
variable "memory_usage_enabled" {
  default     = false
  description = "Enable Service Bus memory monitor (disabled by default; emitted only by Premium SKU namespaces)"
  type        = bool
}

variable "memory_usage_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "memory_usage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "memory_usage_threshold_critical" {
  default     = 90
  description = "Namespace memory percentage at which to alert critical"
  type        = number
}

variable "memory_usage_threshold_warning" {
  default     = 80
  description = "Namespace memory percentage at which to alert warning"
  type        = number
}

variable "memory_usage_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Service Bus memory monitor"
  type        = bool
}
