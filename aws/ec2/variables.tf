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

#####################################
# EC2 instance status checsk
########################################
variable "status_failed_check_enabled" {
  default     = true
  description = "Enable ec2 instance status check monitor"
  type        = bool
}

variable "status_failed_check_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "status_failed_check_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "status_failed_check_use_message" {
  description = "Whether to use the query alert base message for ec2 instance status check monitor"
  type        = bool
  default     = false
}

########################################
# Instance status check
########################################
variable "status_failed_instance_enabled" {
  default     = true
  description = "Enable instance status check monitor"
  type        = bool
}

variable "status_failed_instance_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "status_failed_instance_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "status_failed_instance_use_message" {
  description = "Whether to use the query alert base message for instance status check monitor"
  type        = bool
  default     = false
}

#####################################
# system host status check
########################################
variable "status_failed_system_enabled" {
  default     = true
  description = "Enable instance system failure monitor"
  type        = bool
}

variable "status_failed_system_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "status_failed_system_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "status_failed_system_use_message" {
  description = "Whether to use the query alert base message for instance system failure monitor"
  type        = bool
  default     = false
}

#####################################
# Attached volume status check
########################################
variable "status_failed_volume_enabled" {
  default     = true
  description = "Enable attached volume status monitor"
  type        = bool
}

variable "status_failed_volume_evaluation_window" {
  default     = "last_5m"
  description = "Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`]"
  type        = string
}

variable "status_failed_volume_no_data_window" {
  default     = 10
  description = "No data threshold (in minutes, 0 to disable)"
  type        = number
}

variable "status_failed_volume_use_message" {
  description = "Whether to use the query alert base message for attached volume status monitor"
  type        = bool
  default     = false
}
