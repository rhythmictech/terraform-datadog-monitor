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
# Num Process Check
########################################
variable "num_process_check_enabled" {
  description = "Flag to enable Num Process Check monitor"
  type        = string
  default     = "true"
}

variable "num_process_check_aggregator" {
  description = "Aggregation method for Num Process Check [available values: `min, max, avg, sum`]"
  type        = string
  default     = "min"
}

variable "num_process_check_timeframe" {
  description = "Monitor timeframe for Num Process Check [available values: `last_#m` (1, 5, 10, 15, or 30), `last_#h` (1, 2, or 4), or `last_1d`]"
  type        = string
  default     = "last_5m"
}

variable "num_process_check_threshold_warning" {
  description = "Num Process Check warning threshold"
  type        = number
  default     = 2
}

variable "num_process_check_threshold_critical" {
  description = "Num Process Check critical threshold"
  type        = number
  default     = 1
}

variable "num_process_check_operator" {
  description = "Operator for Num Process Check Query [available values: `<, >, <=, >=, =`]"
  type        = string
  default     = "<="
}
