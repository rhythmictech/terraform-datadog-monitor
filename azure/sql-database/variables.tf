########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:sql-database"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Database CPU utilization
########################################
variable "cpu_high_enabled" {
  default     = true
  description = "Enable SQL Database CPU utilization monitor"
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
  description = "Database CPU utilization percentage at which to alert critical"
  type        = number
}

variable "cpu_high_threshold_warning" {
  default     = 80
  description = "Database CPU utilization percentage at which to alert warning"
  type        = number
}

variable "cpu_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database CPU utilization monitor"
  type        = bool
}

########################################
# Database storage utilization
########################################
variable "storage_high_enabled" {
  default     = true
  description = "Enable SQL Database storage utilization monitor"
  type        = bool
}

variable "storage_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "storage_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "storage_high_threshold_critical" {
  default     = 90
  description = "Database storage utilization percentage at which to alert critical"
  type        = number
}

variable "storage_high_threshold_warning" {
  default     = 80
  description = "Database storage utilization percentage at which to alert warning"
  type        = number
}

variable "storage_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database storage utilization monitor"
  type        = bool
}

########################################
# Deadlocks
########################################
variable "deadlocks_enabled" {
  default     = true
  description = "Enable SQL Database deadlock monitor"
  type        = bool
}

variable "deadlocks_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "deadlocks_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "deadlocks_threshold_critical" {
  default     = 5
  description = "Number of deadlocks in the evaluation window at which to alert critical"
  type        = number
}

variable "deadlocks_threshold_warning" {
  default     = 1
  description = "Number of deadlocks in the evaluation window at which to alert warning"
  type        = number
}

variable "deadlocks_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database deadlock monitor"
  type        = bool
}

########################################
# Connection failures
########################################
variable "connection_failures_enabled" {
  default     = true
  description = "Enable SQL Database failed connection monitor"
  type        = bool
}

variable "connection_failures_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "connection_failures_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "connection_failures_threshold_critical" {
  default     = 10
  description = "Number of failed connections in the evaluation window at which to alert critical"
  type        = number
}

variable "connection_failures_threshold_warning" {
  default     = 1
  description = "Number of failed connections in the evaluation window at which to alert warning"
  type        = number
}

variable "connection_failures_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database failed connection monitor"
  type        = bool
}

########################################
# Worker utilization
########################################
variable "workers_high_enabled" {
  default     = true
  description = "Enable SQL Database worker utilization monitor"
  type        = bool
}

variable "workers_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "workers_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "workers_high_threshold_critical" {
  default     = 90
  description = "Worker utilization percentage at which to alert critical"
  type        = number
}

variable "workers_high_threshold_warning" {
  default     = 80
  description = "Worker utilization percentage at which to alert warning"
  type        = number
}

variable "workers_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database worker utilization monitor"
  type        = bool
}

########################################
# Session utilization
########################################
variable "sessions_high_enabled" {
  default     = true
  description = "Enable SQL Database session utilization monitor"
  type        = bool
}

variable "sessions_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "sessions_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "sessions_high_threshold_critical" {
  default     = 90
  description = "Session utilization percentage at which to alert critical"
  type        = number
}

variable "sessions_high_threshold_warning" {
  default     = 80
  description = "Session utilization percentage at which to alert warning"
  type        = number
}

variable "sessions_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database session utilization monitor"
  type        = bool
}

########################################
# Log write utilization (disabled by default)
########################################
variable "log_write_high_enabled" {
  default     = false
  description = "Enable SQL Database log write utilization monitor. Disabled by default: write-heavy batch and ETL workloads saturate the log writer during normal operation, so this needs a per-database threshold before it is useful"
  type        = bool
}

variable "log_write_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "log_write_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "log_write_high_threshold_critical" {
  default     = 90
  description = "Log write utilization percentage at which to alert critical"
  type        = number
}

variable "log_write_high_threshold_warning" {
  default     = 80
  description = "Log write utilization percentage at which to alert warning"
  type        = number
}

variable "log_write_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database log write utilization monitor"
  type        = bool
}

########################################
# DTU consumption (disabled by default, DTU purchasing model only)
########################################
variable "dtu_consumption_high_enabled" {
  default     = false
  description = "Enable SQL Database DTU consumption monitor. Disabled by default: `dtu_consumption_percent` is emitted only under the DTU purchasing model, so a vCore database reports nothing and the monitor would sit in no-data. Use `cpu_high_enabled`, which is valid under both models, and enable this only for DTU-model databases"
  type        = bool
}

variable "dtu_consumption_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "dtu_consumption_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "dtu_consumption_high_threshold_critical" {
  default     = 90
  description = "DTU consumption percentage at which to alert critical"
  type        = number
}

variable "dtu_consumption_high_threshold_warning" {
  default     = 80
  description = "DTU consumption percentage at which to alert warning"
  type        = number
}

variable "dtu_consumption_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Database DTU consumption monitor"
  type        = bool
}
