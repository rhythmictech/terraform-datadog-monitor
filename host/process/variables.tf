########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:ec2"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Process Alert
########################################
variable "process_alert_enabled" {
  description = "Flag to enable Process Check monitor"
  type        = string
  default     = "true"
}

variable "process_alert_process_name" {
  description = "Name of Process for Process Alert"
  type        = string
  default     = ""
}

variable "process_alert_timeframe" {
  description = "Monitor timeframe for Process Alert [available values: `#m` (1, 5, 10, 15, or 30), `#h` (1, 2, or 4), or `1d`]"
  type        = string
  default     = "5m"
}

variable "process_alert_threshold_warning" {
  description = "Process Alert warning threshold"
  type        = number
  default     = null
}

variable "process_alert_threshold_critical" {
  description = "Process Alert critical threshold"
  type        = number
  default     = 1
}

variable "process_alert_operator" {
  description = "Operator for Process Alert Query [available values: `<, >, <=, >=, =`]"
  type        = string
  default     = "<"
}

variable "process_alert_use_message" {
  description = "Flag to enable Process Check alerting"
  type        = string
  default     = "true"
}