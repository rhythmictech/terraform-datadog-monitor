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
# Disk Space
########################################
variable "disk_space_enabled" {
  description = "Flag to enable Free diskspace monitor"
  type        = string
  default     = "true"
}

variable "disk_space_time_aggregator" {
  description = "Monitor aggregator for Free diskspace [available values: min, max or avg]"
  type        = string
  default     = "max"
}

variable "disk_space_timeframe" {
  description = "Monitor timeframe for Free diskspace [available values: `last_#m` (1, 5, 10, 15, or 30), `last_#h` (1, 2, or 4), or `last_1d`]"
  type        = string
  default     = "last_5m"
}

variable "disk_space_threshold_warning" {
  description = "Free disk space warning threshold"
  type        = number
  default     = 80
}

variable "disk_space_threshold_critical" {
  description = "Free disk space critical threshold"
  type        = number
  default     = 90
}

variable "disk_space_use_message" {
  description = "Flag to enable Free diskspace alerting"
  type        = string
  default     = "true"
}

########################################
# Disk Space Forecast
########################################
variable "disk_space_forecast_enabled" {
  description = "Flag to enable Free diskspace forecast monitor"
  type        = string
  default     = "true"
}

variable "disk_space_forecast_time_aggregator" {
  description = "Monitor aggregator for Free diskspace forecast [available values: min, max or avg]"
  type        = string
  default     = "max"
}

variable "disk_space_forecast_timeframe" {
  description = "Monitor timeframe for Free diskspace forecast [available values: `next_12h`, `next_#d` (1, 2, or 3), `next_#w` (1 or 2) or `next_#mo` (1, 2 or 3)]"
  type        = string
  default     = "next_1w"
}

variable "disk_space_forecast_algorithm" {
  description = "Algorithm for the Free diskspace Forecast monitor [available values: `linear` or `seasonal`]"
  type        = string
  default     = "linear"
}

variable "disk_space_forecast_deviations" {
  description = "Deviations for the Free diskspace Forecast monitor [available values: `1`, `2`, `3`, `4` or `5`]"
  type        = string
  default     = 1
}

variable "disk_space_forecast_interval" {
  description = "Interval for the Free diskspace Forecast monitor [available values: `30m`, `60m` or `120m`]"
  type        = string
  default     = "60m"
}

variable "disk_space_forecast_linear_history" {
  description = "History for the Free diskspace Forecast monitor [available values: `12h`, `#d` (1, 2, or 3), `#w` (1, or 2) or `#mo` (1, 2 or 3)]"
  type        = string
  default     = "1w"
}

variable "disk_space_forecast_linear_model" {
  description = "Model for the Free diskspace Forecast monitor [available values: `default`, `simple` or `reactive`]"
  type        = string
  default     = "default"
}

variable "disk_space_forecast_seasonal_seasonality" {
  description = "Seasonality for the Free diskspace Forecast monitor"
  type        = string
  default     = "weekly"
}

variable "disk_space_forecast_threshold_critical_recovery" {
  description = "Free disk space forecast recovery threshold"
  type        = number
  default     = 72
}

variable "disk_space_forecast_threshold_critical" {
  description = "Free disk space forecast critical threshold"
  type        = number
  default     = 80
}

variable "disk_space_forecast_use_message" {
  description = "Flag to enable Free diskspace forecast alerting"
  type        = string
  default     = "false"
}

########################################
# Disk Inodes
########################################
variable "disk_inodes_enabled" {
  description = "Flag to enable Free disk inodes monitor"
  type        = string
  default     = "true"
}

variable "disk_inodes_time_aggregator" {
  description = "Monitor aggregator for Free disk inodes [available values: min, max or avg]"
  type        = string
  default     = "min"
}

variable "disk_inodes_timeframe" {
  description = "Monitor timeframe for Free disk inodes [available values: `last_#m` (1, 5, 10, 15, or 30), `last_#h` (1, 2, or 4), or `last_1d`]"
  type        = string
  default     = "last_5m"
}

variable "disk_inodes_threshold_warning" {
  description = "Free disk space warning threshold"
  type        = number
  default     = 90
}

variable "disk_inodes_threshold_critical" {
  description = "Free disk space critical threshold"
  type        = number
  default     = 95
}

variable "disk_inodes_use_message" {
  description = "Flag to enable Free disk inodes alerting"
  type        = string
  default     = "true"
}