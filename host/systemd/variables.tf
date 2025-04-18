variable "systemd_unit_alert_enabled" {
  description = "Enable or disable the Systemd service alert monitor"
  type        = bool
  default     = true
}

variable "systemd_unit_alert_use_message" {
  description = "Whether to use the base message for the Systemd service alert"
  type        = bool
  default     = true
}

variable "systemd_unit_alert_threshold_critical" {
  description = "Critical threshold for the Systemd service alert (count of services not running/failed)"
  type        = number
  default     = 2
}

variable "systemd_unit_alert_threshold_warning" {
  description = "Warning threshold for the Systemd service alert (count of services not running/failed)"
  type        = number
  default     = 1
}

variable "systemd_units_filter" {
  description = "List of specific systemd units (services) to monitor. If empty, monitors all."
  type        = list(string)
  default     = []
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