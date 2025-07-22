########################################
# Global variables
########################################
variable "additional_tags" {
  default     = []
  description = "Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`)"
  type        = list(string)
}

variable "base_tags" {
  default     = []
  description = "Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this)"
  type        = list(string)
}

########################################
# SSL Synthetic Test variables
########################################
variable "ssl_synthetic_enabled" {
  description = "Flag to enable SSL Synthetic Test"
  type        = string
  default     = "true"
}

variable "ssl_synthetic_locations" {
  description = "An array of datadog locations used to run SSL Synthetic Test"
  type        = list(string)
  default     = ["aws:us-east-1"]
}

variable "ssl_synthetic_host" {
  description = "Host name to perform SSL Synthetic Test with."
  type        = string
}

variable "ssl_synthetic_port" {
  description = "Port to use when performing SSL Synthetic Test."
  type        = number
  default     = 443
}

variable "ssl_synthetic_days_to_expiration" {
  description = "Number of Days till certificate expiration for SSL Synthetic Test to alert."
  type        = number
  default     = 30
}

variable "ssl_synthetic_min_tls_version" {
  description = "Number Certificate TLS version should be equal to or greater than."
  type        = number
  default     = 1.2
}

variable "ssl_synthetic_max_response_time" {
  description = "Number of milliseconds host response time should be less than."
  type        = number
  default     = 2000
}

variable "ssl_synthetic_renotify_interval" {
  description = "How often SSL Synthetic Test should renotify in minutes."
  type        = number
  default     = 10080
}

variable "ssl_synthetic_tick_every" {
  description = "How often SSL Synthetic Test should run in seconds."
  type        = number
  default     = 86400
}

variable "ssl_synthetic_accept_self_signed" {
  description = "Whether or not SSL Synthetic Test should allow self signed certificates."
  type        = bool
  default     = false
}

variable "ssl_synthetic_tls_check_enabled" {
  type        = bool
  description = "Enable TLS version checking in the synthetic test"
  default     = false
}

variable "ssl_synthetic_response_time_check_enabled" {
  type        = bool
  description = "Enable response time checking in the synthetic test"
  default     = false
}
