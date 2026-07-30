########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:vm"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# VM availability
########################################
variable "availability_enabled" {
  default     = true
  description = "Enable VM availability monitor"
  type        = bool
}

variable "availability_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "availability_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "availability_use_message" {
  default     = false
  description = "Whether to use the query alert base message for VM availability monitor"
  type        = bool
}

########################################
# CPU utilization
########################################
variable "cpu_high_enabled" {
  default     = true
  description = "Enable VM CPU utilization monitor"
  type        = bool
}

variable "cpu_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_high_threshold_critical" {
  default     = 90
  description = "CPU utilization percentage at which to alert critical"
  type        = number
}

variable "cpu_high_threshold_warning" {
  default     = 80
  description = "CPU utilization percentage at which to alert warning"
  type        = number
}

variable "cpu_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for VM CPU utilization monitor"
  type        = bool
}

########################################
# Available memory
########################################
variable "memory_low_enabled" {
  default     = true
  description = "Enable VM available memory monitor"
  type        = bool
}

variable "memory_low_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "memory_low_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "memory_low_threshold_critical" {
  default     = 10
  description = "Available memory percentage below which to alert critical"
  type        = number
}

variable "memory_low_threshold_warning" {
  default     = 20
  description = "Available memory percentage below which to alert warning"
  type        = number
}

variable "memory_low_use_message" {
  default     = false
  description = "Whether to use the query alert base message for VM available memory monitor"
  type        = bool
}

########################################
# OS disk IOPS saturation
########################################
variable "os_disk_iops_saturation_enabled" {
  default     = true
  description = "Enable VM OS disk IOPS saturation monitor"
  type        = bool
}

variable "os_disk_iops_saturation_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "os_disk_iops_saturation_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "os_disk_iops_saturation_threshold_critical" {
  default     = 95
  description = "OS disk consumed-IOPS percentage at which to alert critical"
  type        = number
}

variable "os_disk_iops_saturation_threshold_warning" {
  default     = 85
  description = "OS disk consumed-IOPS percentage at which to alert warning"
  type        = number
}

variable "os_disk_iops_saturation_use_message" {
  default     = false
  description = "Whether to use the query alert base message for VM OS disk IOPS saturation monitor"
  type        = bool
}

########################################
# Data disk IOPS saturation
########################################
variable "data_disk_iops_saturation_enabled" {
  default     = true
  description = "Enable VM data disk IOPS saturation monitor"
  type        = bool
}

variable "data_disk_iops_saturation_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "data_disk_iops_saturation_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "data_disk_iops_saturation_threshold_critical" {
  default     = 95
  description = "Data disk consumed-IOPS percentage at which to alert critical"
  type        = number
}

variable "data_disk_iops_saturation_threshold_warning" {
  default     = 85
  description = "Data disk consumed-IOPS percentage at which to alert warning"
  type        = number
}

variable "data_disk_iops_saturation_use_message" {
  default     = false
  description = "Whether to use the query alert base message for VM data disk IOPS saturation monitor"
  type        = bool
}

########################################
# CPU burst credits (B-series burstable VMs only)
########################################
variable "cpu_credits_low_enabled" {
  default     = false
  description = "Enable VM CPU burst credit monitor (B-series burstable VMs only; the metric is not emitted by other SKUs)"
  type        = bool
}

variable "cpu_credits_low_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "cpu_credits_low_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "cpu_credits_low_threshold_critical" {
  default     = 10
  description = "Remaining CPU burst credits below which to alert critical"
  type        = number
}

variable "cpu_credits_low_threshold_warning" {
  default     = 25
  description = "Remaining CPU burst credits below which to alert warning"
  type        = number
}

variable "cpu_credits_low_use_message" {
  default     = false
  description = "Whether to use the query alert base message for VM CPU burst credit monitor"
  type        = bool
}
