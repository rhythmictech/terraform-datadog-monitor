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
# Host Unreachable
########################################
variable "system_clock_enabled" {
  default     = true
  description = "Flag to enable Host unreachable monitor"
  type        = bool
}

variable "system_clock_use_message" {
  default     = false
  description = "Flag to enable Host unreachable alerting"
  type        = bool
}