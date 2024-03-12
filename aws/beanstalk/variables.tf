########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:beanstalk"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Health Monitor
########################################
variable "health_enabled" {
  default     = false
  description = "Enable Beanstalk health monitor (requires enhanced metrics)"
  type        = bool
}

variable "health_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`)"
  type        = string
}

variable "health_no_data_window" {
  default     = 20
  description = "No date threshold (minutes)"
  type        = number
}

variable "health_threshold_critical" {
  default = 25
  type    = number

  description = <<END
Critical threshold (
    0 = OK
    1 = Info
    5 = Unknown
    10 =  No data
    15 =  Warning
    20 = Degraded
    25 = Severe
)
END
}

variable "health_threshold_warning" {
  default = 20
  type    = number

  description = <<END
Warning threshold (
    0 = OK
    1 = Info
    5 = Unknown
    10 =  No data
    15 =  Warning
    20 = Degraded
    25 = Severe
)
END
}

########################################
# HTTP 5xx Responses
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
  default     = 75
  description = "Critical threshold (percentage)"
  type        = number
}

variable "http_5xx_responses_threshold_warning" {
  default     = 25
  description = "Warning threshold (percentage)"
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

variable "latency_measurement" {
  default = "p50"
  type    = string

  description = <<END
Latency Measurement

Valid options:
* p10
* p50
* p75
* p85
* p90
* p95
* p99
* p99_9
END
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

########################################
# Root FS Disk Usage
########################################
variable "root_disk_usage_enabled" {
  default     = false
  description = "Enable root disk usage monitor"
  type        = bool
}

variable "root_disk_usage_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "root_disk_usage_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "root_disk_usage_threshold_critical" {
  default     = 90
  description = "Critical threshold (percent)"
  type        = number
}

variable "root_disk_usage_threshold_warning" {
  default     = 80
  description = "Warning threshold (percent)"
  type        = number
}
