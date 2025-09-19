# tflint-ignore-file: terraform_unused_declarations

########################################
# Tag Related Vars
########################################
variable "cost_center" {
  default     = null
  description = "Cost Center of the monitored resource (leave blank to omit tag)"
  type        = string
}

variable "env" {
  default     = null
  description = "Environment the monitored resource is in (leave blank to omit tag)"
  type        = string
}

variable "service" {
  default     = null
  description = "Service associated with the monitored resource (leave blank to omit tag)"
  type        = string
}

variable "team" {
  default     = null
  description = "Team supporting the monitored resource (leave blank to omit tag)"
  type        = string
}

########################################
# Filter Vars
########################################
variable "monitor_exclude_tags" {
  default     = []
  description = "Tags to be excluded in the monitoring query. Specify in key:value format"
  type        = list(string)
}

variable "monitor_include_tags" {
  default     = []
  description = "Tags to be included in the monitoring query. Specify in key:value format"
  type        = list(string)
}

########################################
# Threshold/Time Vars
########################################
variable "evaluation_delay" {
  default     = 900
  description = "Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs))"
  type        = number
}

variable "new_group_delay" {
  default     = 300
  description = "Delay in seconds before generating alerts for a new resource"
  type        = number
}

variable "notify_no_data" {
  default     = false
  description = "Alert if no matching data is found"
  type        = bool
}

variable "renotify_interval" {
  default     = 60
  description = "Interval in minutes to re-send notifications about an alert"
  type        = number
}

variable "timeout_h" {
  default     = 0
  description = "Auto-resolve alert in specified hours if condition no longer matches"
  type        = number
}

########################################
# Alert Priority Vars
########################################
variable "alert_critical_priority" {
  default     = null
  description = "Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified)"
  type        = string
}

variable "alert_nodata_priority" {
  default     = null
  description = "Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified)"
  type        = string
}

variable "warn_priority" {
  default     = null
  description = "Priority for alerts with no data (P1-P5, uses monitor defaults if not specified)"
  type        = string
}

########################################
# Alert Message Vars
########################################
variable "alert_message" {
  default     = "Alert"
  description = "Message to prepend to alert notifications"
  type        = string
}

variable "dashboard_link" {
  default     = null
  description = "Dashboard link to include in message"
  type        = string
}

variable "runbook_link" {
  default     = null
  description = "Runbook link to include in message"
  type        = string
}

variable "title_prefix" {
  default     = null
  description = "Prefix all alerts with specified value in brackets"
  type        = string
}

variable "title_suffix" {
  default     = null
  description = "Suffix all alerts with specified value in parenthesis"
  type        = string
}

########################################
# Notification Vars
########################################
variable "notify_default" {
  description = "List of alert notifications (can be overridden based on alert type)"
  type        = list(string)
}

variable "notify_alert_override" {
  default     = []
  description = "List of notifications for alerts in critical threshold (uses `notify_default` otherwise)"
  type        = list(string)
}

variable "notify_warn_override" {
  default     = []
  description = "List of notifications for alerts in warning threshold (uses `notify_default` otherwise)"
  type        = list(string)
}

variable "notify_nodata_override" {
  default     = []
  description = "List of notifications for no data (uses `notify_default` otherwise)"
  type        = list(string)
}

variable "notify_recovery_override" {
  default     = []
  description = "List of notifications for alert recovery (uses `notify_default` otherwise)"
  type        = list(string)
}

variable "notify_crit_override" {
  default     = []
  description = "List of notifications for 24x7 alerts in critical threshold (uses `notify_default` otherwise)"
  type        = list(string)
}

variable "notify_nonprod_override" {
  default     = []
  description = "List of notifications for non-prod alerts in critical threshold (uses `notify_default` otherwise)"
  type        = list(string)
}

variable "notify_prod_override" {
  default     = []
  description = "List of notifications for 12x5 prod alerts in critical threshold (uses `notify_default` otherwise)"
  type        = list(string)
}

variable "group_by" {
  default     = ["name", "aws_account", "env", "datadog_managed"]
  description = "List of tags to group by"
  type        = list(string)
}

locals {

  # tag related locals
  common_tags = concat(
    var.cost_center != null ? ["cost_center:${var.cost_center}"] : [],
    var.env != null ? ["env:${var.env}"] : [],
    var.service != null ? ["service:${var.service}"] : [],
    var.team != null ? ["team:${var.team}"] : [],
    ["provisioned-by:terraform"]
  )

  # monitor filters
  include_tags = length(var.monitor_include_tags) > 0 || length(var.monitor_exclude_tags) > 0 ? var.monitor_include_tags : ["*"]

  # format: {tag1:val1,tag2:val2,!excludedtag1:value1,!exludedtag2:value2}
  query_filter = "{${replace(join(",", compact(
    concat(
      formatlist(" !%s", var.monitor_exclude_tags),
      local.include_tags
    )
    )
  ), "/ +/", " ")}}"

  # event_alert = tag:val tag2:val2 -excludedtag1:value1 -exludedtag2:value2
  event_filter = replace(join(" ", compact(
    concat(
      formatlist(" -%s", var.monitor_exclude_tags),
      local.include_tags
    )
    )
  ), "/ +/", " ")

  service_filter_dirty = join("", compact(concat([
    ".over(",
    join(",", formatlist("\"%s\"", local.include_tags)),
    ")"
    ], length(var.monitor_exclude_tags) == 0 ? [] : [
    ".exclude(",
    join(",", formatlist("\"%s\"", var.monitor_exclude_tags)),
    ")"
    ]
  )))

  # format: .over("tag1:val1","tag2:val2").exclude("excludedtag1:value1","exludedtag2:value2")
  service_filter = replace(replace(local.service_filter_dirty, "\"(", "(\""), ")\"", "\")")

  # notification / alert message locals
  alert_context = join("\n", concat(
    [var.alert_message],
    var.dashboard_link != null ? ["**Dashboard**: ${var.dashboard_link}"] : [],
    var.runbook_link != null ? ["**Runbook**: ${var.runbook_link}"] : []
  ))

  alert_priority  = coalesce(var.alert_critical_priority, "P2")
  warn_priority   = coalesce(var.warn_priority, "P2")
  nodata_priority = coalesce(var.alert_nodata_priority, "P2")

  notify_on_alert    = join(" ", coalescelist(var.notify_alert_override, var.notify_default))
  notify_on_warn     = join(" ", coalescelist(var.notify_warn_override, var.notify_default))
  notify_on_nodata   = join(" ", coalescelist(var.notify_nodata_override, var.notify_default))
  notify_on_recovery = join(" ", coalescelist(var.notify_recovery_override, var.notify_default))
  notify_on_crit     = join(" ", coalescelist(var.notify_crit_override, var.notify_default))
  notify_on_nonprod  = join(" ", coalescelist(var.notify_nonprod_override, var.notify_default))
  notify_on_prod     = join(" ", coalescelist(var.notify_prod_override, var.notify_default))

  log_alert_base_message = <<END
${local.alert_context}

**Alert Information**
* **Status**: {{log.status}}
* **Service**: {{log.service}}
* **Source**: {{log.source}}
* **Message**: {{log.message}}
* **Direct Link**: {{log.link}}
{{#is_alert}}
{{#is_match "env.name" "prod" "prd"}}
  {{#is_match "datadog_managed" "critical"}}
    ${local.notify_on_crit}
  {{/is_match}}
  {{#is_match "datadog_managed" "true"}}
    ${local.notify_on_prod}
  {{/is_match}}
{{/is_match}}
{{^is_match "env.name" "prod" "prd"}}
    ${local.notify_on_nonprod}
  {{/is_match}}
{{/is_match}}
{{/is_alert}}
{{#is_recovery}}
{{#is_match "env.name" "prod" "prd"}}
  {{#is_match "datadog_managed" "critical"}}
    ${local.notify_on_crit}
  {{/is_match}}
  {{#is_match "datadog_managed" "true"}}
    ${local.notify_on_prod}
  {{/is_match}}
{{/is_match}}
{{^is_match "env.name" "prod" "prd"}}
    ${local.notify_on_nonprod}
  {{/is_match}}
{{/is_match}}
{{/is_recovery}}
END

  query_alert_base_message = <<END
${local.alert_context}
{{#is_alert}}
Current value: {{value}}
Threshold: {{threshold}}

Environment: {{env.name}}

  {{#is_match "env.name" "prod" "prd"}}
    {{#is_match "datadog_managed" "critical"}}
      ${local.notify_on_crit}
    {{/is_match}}
    {{#is_match "datadog_managed" "true"}}
      ${local.notify_on_prod}
    {{/is_match}}
  {{/is_match}}
  {{^is_match "env.name" "prod" "prd"}}
      ${local.notify_on_nonprod}
  {{/is_match}}

Please investigate and take necessary actions.
{{/is_alert}}

{{#is_recovery}}
Recovery: Monitor has returned to a normal state.

Current value: {{value}}
Threshold: {{threshold}}

Environment: {{env.name}}

No further action is required.

  {{#is_match "env.name" "prod" "prd"}}
    {{#is_match "datadog_managed" "critical"}}
      ${local.notify_on_crit}
    {{/is_match}}
    {{#is_match "datadog_managed" "true"}}
      ${local.notify_on_prod}
    {{/is_match}}
  {{/is_match}}
  {{^is_match "env.name" "prod" "prd"}}
      ${local.notify_on_nonprod}
  {{/is_match}}
{{/is_recovery}}
END

  synthetic_alert_base_message = <<END
${local.alert_context}
**Alert Information**
{{#is_alert}} ${local.notify_on_alert} {{/is_alert}}
{{#is_recovery}} ${local.notify_on_recovery} {{/is_recovery}}
END

  service_group_by = join(",", formatlist("\"%s\"", var.group_by))
  query_group_by   = join(",", var.group_by)
}
