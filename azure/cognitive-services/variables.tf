########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:cognitive-services"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Error rate
########################################
variable "error_rate_enabled" {
  default     = true
  description = "Enable Cognitive Services error rate monitor"
  type        = bool
}

variable "error_rate_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "error_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "error_rate_threshold_critical" {
  default     = 5
  description = "Percentage of calls returning errors at which to alert critical"
  type        = number
}

variable "error_rate_threshold_warning" {
  default     = 1
  description = "Percentage of calls returning errors at which to alert warning"
  type        = number
}

variable "error_rate_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Cognitive Services error rate monitor"
  type        = bool
}

########################################
# Availability rate
########################################
variable "availability_rate_enabled" {
  default     = true
  description = "Enable Cognitive Services availability rate monitor"
  type        = bool
}

variable "availability_rate_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "availability_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "availability_rate_threshold_critical" {
  default     = 95
  description = "Availability rate percentage below which to alert critical"
  type        = number
}

variable "availability_rate_threshold_warning" {
  default     = 99
  description = "Availability rate percentage below which to alert warning"
  type        = number
}

variable "availability_rate_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Cognitive Services availability rate monitor"
  type        = bool
}

########################################
# Blocked calls
########################################
variable "blocked_calls_enabled" {
  default     = true
  description = "Enable Cognitive Services blocked call monitor (quota and rate-limit rejections)"
  type        = bool
}

variable "blocked_calls_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "blocked_calls_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "blocked_calls_threshold_critical" {
  default     = 0
  description = "Blocked call count above which to alert critical (the default of 0 alerts on any blocked call in the evaluation window)"
  type        = number
}

variable "blocked_calls_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Cognitive Services blocked call monitor"
  type        = bool
}

########################################
# Latency
########################################
variable "latency_enabled" {
  default     = false
  description = "Enable Cognitive Services latency monitor (disabled by default; Datadog does not document the metric unit, so confirm against live data before enabling)"
  type        = bool
}

variable "latency_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "latency_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "latency_threshold_critical" {
  default     = 5000
  description = "Latency at which to alert critical (assumed milliseconds; confirm the metric unit before relying on this)"
  type        = number
}

variable "latency_threshold_warning" {
  default     = 2000
  description = "Latency at which to alert warning (assumed milliseconds; confirm the metric unit before relying on this)"
  type        = number
}

variable "latency_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Cognitive Services latency monitor"
  type        = bool
}

########################################
# Provisioned throughput utilization (PTU deployments only)
########################################
variable "provisioned_utilization_enabled" {
  default     = false
  description = "Enable Cognitive Services provisioned utilization monitor (disabled by default; emitted only by provisioned-throughput (PTU) deployments)"
  type        = bool
}

variable "provisioned_utilization_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "provisioned_utilization_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "provisioned_utilization_threshold_critical" {
  default     = 90
  description = "Provisioned throughput utilization percentage at which to alert critical"
  type        = number
}

variable "provisioned_utilization_threshold_warning" {
  default     = 80
  description = "Provisioned throughput utilization percentage at which to alert warning"
  type        = number
}

variable "provisioned_utilization_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Cognitive Services provisioned utilization monitor"
  type        = bool
}

########################################
# Model availability rate (Azure OpenAI only)
########################################
variable "model_availability_rate_enabled" {
  default     = false
  description = "Enable Cognitive Services model availability monitor (disabled by default; Azure OpenAI deployments only)"
  type        = bool
}

variable "model_availability_rate_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "model_availability_rate_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "model_availability_rate_threshold_critical" {
  default     = 95
  description = "Model availability rate percentage below which to alert critical"
  type        = number
}

variable "model_availability_rate_threshold_warning" {
  default     = 99
  description = "Model availability rate percentage below which to alert warning"
  type        = number
}

variable "model_availability_rate_use_message" {
  default     = false
  description = "Whether to use the query alert base message for Cognitive Services model availability monitor"
  type        = bool
}
