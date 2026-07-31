########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = ["resource:sql-elastic-pool"]
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# Pool CPU utilization
########################################
variable "cpu_high_enabled" {
  default     = true
  description = "Enable SQL Elastic Pool CPU utilization monitor"
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
  description = "Pool CPU utilization percentage at which to alert critical"
  type        = number
}

variable "cpu_high_threshold_warning" {
  default     = 80
  description = "Pool CPU utilization percentage at which to alert warning"
  type        = number
}

variable "cpu_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Elastic Pool CPU utilization monitor"
  type        = bool
}

########################################
# Pool storage utilization
########################################
variable "storage_high_enabled" {
  default     = true
  description = "Enable SQL Elastic Pool storage utilization monitor"
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
  description = "Pool storage utilization percentage at which to alert critical"
  type        = number
}

variable "storage_high_threshold_warning" {
  default     = 80
  description = "Pool storage utilization percentage at which to alert warning"
  type        = number
}

variable "storage_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Elastic Pool storage utilization monitor"
  type        = bool
}

########################################
# Pool worker utilization
########################################
variable "workers_high_enabled" {
  default     = true
  description = "Enable SQL Elastic Pool worker utilization monitor"
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
  description = "Pool worker utilization percentage at which to alert critical"
  type        = number
}

variable "workers_high_threshold_warning" {
  default     = 80
  description = "Pool worker utilization percentage at which to alert warning"
  type        = number
}

variable "workers_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Elastic Pool worker utilization monitor"
  type        = bool
}

########################################
# Pool session utilization
########################################
variable "sessions_high_enabled" {
  default     = true
  description = "Enable SQL Elastic Pool session utilization monitor"
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
  description = "Pool session utilization percentage at which to alert critical"
  type        = number
}

variable "sessions_high_threshold_warning" {
  default     = 80
  description = "Pool session utilization percentage at which to alert warning"
  type        = number
}

variable "sessions_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Elastic Pool session utilization monitor"
  type        = bool
}

########################################
# Pool log write utilization (disabled by default)
########################################
variable "log_write_high_enabled" {
  default     = false
  description = "Enable SQL Elastic Pool log write utilization monitor. Disabled by default: write-heavy batch and ETL workloads saturate the log writer during normal operation, so this needs a per-pool threshold before it is useful"
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
  description = "Pool log write utilization percentage at which to alert critical"
  type        = number
}

variable "log_write_high_threshold_warning" {
  default     = 80
  description = "Pool log write utilization percentage at which to alert warning"
  type        = number
}

variable "log_write_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Elastic Pool log write utilization monitor"
  type        = bool
}

########################################
# Pool data IO utilization (disabled by default)
########################################
variable "data_io_high_enabled" {
  default     = false
  description = "Enable SQL Elastic Pool data IO monitor. Disabled by default: read-heavy pools sit near the data IO ceiling by design, so this is informational unless the pool is known to be IO constrained"
  type        = bool
}

variable "data_io_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "data_io_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "data_io_high_threshold_critical" {
  default     = 90
  description = "Pool data IO percentage at which to alert critical"
  type        = number
}

variable "data_io_high_threshold_warning" {
  default     = 80
  description = "Pool data IO percentage at which to alert warning"
  type        = number
}

variable "data_io_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Elastic Pool data IO monitor"
  type        = bool
}

########################################
# Pool eDTU consumption (disabled by default, DTU purchasing model only)
########################################
variable "edtu_consumption_high_enabled" {
  default     = false
  description = "Enable SQL Elastic Pool eDTU consumption monitor. Disabled by default: `dtu_consumption_percent` is emitted only under the DTU purchasing model, so a vCore pool reports nothing and the monitor would sit in no-data. Use `cpu_high_enabled`, which is valid under both models, and enable this only for DTU-model pools"
  type        = bool
}

variable "edtu_consumption_high_evaluation_window" {
  default     = "last_15m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "edtu_consumption_high_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "edtu_consumption_high_threshold_critical" {
  default     = 90
  description = "Pool eDTU consumption percentage at which to alert critical"
  type        = number
}

variable "edtu_consumption_high_threshold_warning" {
  default     = 80
  description = "Pool eDTU consumption percentage at which to alert warning"
  type        = number
}

variable "edtu_consumption_high_use_message" {
  default     = false
  description = "Whether to use the query alert base message for SQL Elastic Pool eDTU consumption monitor"
  type        = bool
}
