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
# Browser Synthetic Test variables
########################################
variable "browser_synthetic_enabled" {
  description = "Flag to enable Browser Synthetic Test."
  type        = bool
  default     = true
}

variable "browser_synthetic_device_ids" {
  description = "List with the different device IDs used to run the test. Valid values are laptop_large, tablet, mobile_small, chrome.laptop_large, chrome.tablet, chrome.mobile_small, firefox.laptop_large, firefox.tablet, firefox.mobile_small, edge.laptop_large, edge.tablet, edge.mobile_small."
  type        = list(string)
  default     = ["laptop_large"]
}

variable "browser_synthetic_locations" {
  description = "An array of datadog locations used to run Browser Synthetic Test."
  type        = list(string)
  default     = ["aws:us-east-1"]
}

variable "browser_synthetic_request_url" {
  description = "URL to send Browser Synthetic Test requests to."
  type        = string
}

variable "browser_synthetic_steps" {
  description = "Steps for the Browser Synthetic Test to take."
  type = list(object({
    name = string
    type = string
    params = object({
      attribute            = optional(string)
      check                = optional(string)
      click_type           = optional(string)
      code                 = optional(string)
      delay                = optional(number)
      element              = optional(string)
      element_user_locator = optional(map(string))
      email                = optional(string)
      file                 = optional(string)
      files                = optional(string)
      modifiers            = optional(list(string))
      playing_tab_id       = optional(string)
      request              = optional(string)
      subtest_public_id    = optional(string)
      value                = optional(string)
      variable             = optional(map(string))
      with_click           = optional(bool)
      x                    = optional(number)
      y                    = optional(number)
    })
  }))
}

variable "browser_synthetic_tick_every" {
  description = "How often Browser Synthetic Test should run in seconds."
  type        = number
  default     = 900
}
