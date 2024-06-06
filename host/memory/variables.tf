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
# Memory
########################################
variable "memory_enabled" {
  description = "Flag to enable Free memory monitor"
  type        = string
  default     = "true"
}

variable "memory_time_aggregator" {
  description = "Monitor aggregator for Free memory [available values: min, max or avg]"
  type        = string
  default     = "max"
}

variable "memory_timeframe" {
  description = "Monitor timeframe for Free memory [available values: `last_#m` (1, 5, 10, 15, or 30), `last_#h` (1, 2, or 4), or `last_1d`]"
  type        = string
  default     = "last_5m"
}

variable "memory_threshold_warning" {
  description = "Free disk space warning threshold"
  type        = number
  default     = 10
}

variable "memory_threshold_critical" {
  description = "Free disk space critical threshold"
  type        = number
  default     = 5
}
