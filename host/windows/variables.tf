variable "windows_service_alert_enabled" {
  description = "Enable or disable the Windows service alert monitor"
  type        = bool
  default     = true
}

variable "windows_service_alert_use_message" {
  description = "Whether to use the base message for the Windows service alert"
  type        = bool
  default     = true
}

variable "windows_service_alert_timeframe" {
  description = "Timeframe for the Windows service alert evaluation"
  type        = string
  default     = "5m"
}

variable "windows_service_alert_operator" {
  description = "Operator for the Windows service alert threshold comparison"
  type        = string
  default     = "<"
}

variable "windows_service_alert_threshold_critical" {
  description = "Critical threshold for the Windows service alert"
  type        = number
  default     = 1
}

variable "windows_service_alert_threshold_warning" {
  description = "Warning threshold for the Windows service alert"
  type        = number
  default     = 2
}

variable "base_tags" {
  description = "Base tags to apply to all monitors"
  type        = list(string)
  default     = []
}

variable "additional_tags" {
  description = "Additional tags to apply to all monitors"
  type        = list(string)
  default     = []
}
