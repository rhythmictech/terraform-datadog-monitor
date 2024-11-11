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
# Swap
########################################
variable "swap_enabled" {
  description = "Flag to enable Swap monitor"
  type        = string
  default     = "true"
}

variable "swap_time_aggregator" {
  description = "Monitor aggregator for Free Swap [available values: min, max or avg]"
  type        = string
  default     = "max"
}

variable "swap_timeframe" {
  description = "Monitor timeframe for Free Swap [available values: `last_#m` (1, 5, 10, 15, or 30), `last_#h` (1, 2, or 4), or `last_1d`]"
  type        = string
  default     = "last_5m"
}

variable "swap_threshold_warning" {
  description = "Free Swap warning threshold as percentage"
  type        = number
  default     = 0.3
}

variable "swap_threshold_critical" {
  description = "Free Swap critical threshold as percentage"
  type        = number
  default     = 0.1
}

variable "swap_use_message" {
  description = "Flag to enable Swap alerting"
  type        = string
  default     = "false"
}