########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:queue"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Oldest queued message
########################################
variable "oldest_message_enabled" {
  default     = false
  description = "Enable oldest queued message monitor"
  type        = bool
}

variable "oldest_message_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "oldest_message_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "oldest_message_threshold_critical" {
  default     = 75
  description = "Critical threshold (seconds)"
  type        = number
}

variable "oldest_message_threshold_warning" {
  default     = null
  description = "Warning threshold (seconds)"
  type        = number
}

variable "oldest_message_use_message" {
  description = "Whether to use the query alert base message for oldest message monitor"
  type        = bool
  default     = false
}

########################################
# Lambda queue_depth
########################################
variable "queue_depth_enabled" {
  default     = false
  description = "Enable queue depth count monitor"
  type        = bool
}

variable "queue_depth_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "queue_depth_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "queue_depth_threshold_critical" {
  default     = null
  description = "Critical threshold (count)"
  type        = number
}

variable "queue_depth_threshold_warning" {
  default     = null
  description = "Warning threshold (count)"
  type        = number
}

variable "queue_depth_use_message" {
  description = "Whether to use the query alert base message for queue depth monitor"
  type        = bool
  default     = false
}
