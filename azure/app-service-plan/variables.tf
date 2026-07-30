########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:app-service-plan"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Plan CPU utilization
########################################
variable "cpu_percentage_enabled" {
  default     = true
  description = "Enable App Service Plan CPU utilization monitor"
  type        = bool
}

variable "cpu_percentage_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_percentage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_percentage_threshold_critical" {
  default     = 90
  description = "Plan CPU utilization percentage at which to alert critical"
  type        = number
}

variable "cpu_percentage_threshold_warning" {
  default     = 80
  description = "Plan CPU utilization percentage at which to alert warning"
  type        = number
}

variable "cpu_percentage_use_message" {
  default     = false
  description = "Whether to use the query alert base message for App Service Plan CPU utilization monitor"
  type        = bool
}

########################################
# Plan memory utilization
########################################
variable "memory_percentage_enabled" {
  default     = true
  description = "Enable App Service Plan memory utilization monitor"
  type        = bool
}

variable "memory_percentage_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "memory_percentage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "memory_percentage_threshold_critical" {
  default     = 90
  description = "Plan memory utilization percentage at which to alert critical"
  type        = number
}

variable "memory_percentage_threshold_warning" {
  default     = 80
  description = "Plan memory utilization percentage at which to alert warning"
  type        = number
}

variable "memory_percentage_use_message" {
  default     = false
  description = "Whether to use the query alert base message for App Service Plan memory utilization monitor"
  type        = bool
}

########################################
# HTTP queue length
########################################
variable "http_queue_length_enabled" {
  default     = true
  description = "Enable App Service Plan HTTP queue length monitor"
  type        = bool
}

variable "http_queue_length_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "http_queue_length_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "http_queue_length_threshold_critical" {
  default     = 100
  description = "Number of queued HTTP requests at which to alert critical"
  type        = number
}

variable "http_queue_length_threshold_warning" {
  default     = 25
  description = "Number of queued HTTP requests at which to alert warning"
  type        = number
}

variable "http_queue_length_use_message" {
  default     = false
  description = "Whether to use the query alert base message for App Service Plan HTTP queue length monitor"
  type        = bool
}

########################################
# Disk queue length
########################################
variable "disk_queue_length_enabled" {
  default     = false
  description = "Enable App Service Plan disk queue length monitor (disabled by default; only meaningful for storage-heavy plans)"
  type        = bool
}

variable "disk_queue_length_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "disk_queue_length_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "disk_queue_length_threshold_critical" {
  default     = 100
  description = "Disk queue length at which to alert critical"
  type        = number
}

variable "disk_queue_length_threshold_warning" {
  default     = 25
  description = "Disk queue length at which to alert warning"
  type        = number
}

variable "disk_queue_length_use_message" {
  default     = false
  description = "Whether to use the query alert base message for App Service Plan disk queue length monitor"
  type        = bool
}
