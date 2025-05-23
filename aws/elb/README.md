# terraform-datadog-monitor/aws/elb

Configures the following for Classic ELBs based on tag matches:

* 5xx rate
* 5xx rate (backend)
* latency (backend)
* unhealthy hosts

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.37 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 3.37.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_monitor.http_5xx_backend_responses](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.http_5xx_responses](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.latency](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.no_healthy_instances](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:lb"<br>]</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_http_5xx_backend_responses_enabled"></a> [http\_5xx\_backend\_responses\_enabled](#input\_http\_5xx\_backend\_responses\_enabled) | Enable HTTP 5xx response monitor (backend) | `bool` | `false` | no |
| <a name="input_http_5xx_backend_responses_evaluation_window"></a> [http\_5xx\_backend\_responses\_evaluation\_window](#input\_http\_5xx\_backend\_responses\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_http_5xx_backend_responses_no_data_window"></a> [http\_5xx\_backend\_responses\_no\_data\_window](#input\_http\_5xx\_backend\_responses\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_http_5xx_backend_responses_threshold_critical"></a> [http\_5xx\_backend\_responses\_threshold\_critical](#input\_http\_5xx\_backend\_responses\_threshold\_critical) | Critical threshold (percentage, 0-100) | `number` | `75` | no |
| <a name="input_http_5xx_backend_responses_threshold_warning"></a> [http\_5xx\_backend\_responses\_threshold\_warning](#input\_http\_5xx\_backend\_responses\_threshold\_warning) | Warning threshold (percentage, 0-100) | `number` | `25` | no |
| <a name="input_http_5xx_backend_responses_use_message"></a> [http\_5xx\_backend\_responses\_use\_message](#input\_http\_5xx\_backend\_responses\_use\_message) | Whether to use the query alert base message for HTTP 5xx backend responses monitor | `bool` | `false` | no |
| <a name="input_http_5xx_responses_enabled"></a> [http\_5xx\_responses\_enabled](#input\_http\_5xx\_responses\_enabled) | Enable HTTP 5xx response monitor | `bool` | `false` | no |
| <a name="input_http_5xx_responses_evaluation_window"></a> [http\_5xx\_responses\_evaluation\_window](#input\_http\_5xx\_responses\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_http_5xx_responses_no_data_window"></a> [http\_5xx\_responses\_no\_data\_window](#input\_http\_5xx\_responses\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_http_5xx_responses_threshold_critical"></a> [http\_5xx\_responses\_threshold\_critical](#input\_http\_5xx\_responses\_threshold\_critical) | Critical threshold (percentage, 0-100) | `number` | `75` | no |
| <a name="input_http_5xx_responses_threshold_warning"></a> [http\_5xx\_responses\_threshold\_warning](#input\_http\_5xx\_responses\_threshold\_warning) | Warning threshold (percentage, 0-100) | `number` | `25` | no |
| <a name="input_http_5xx_responses_use_message"></a> [http\_5xx\_responses\_use\_message](#input\_http\_5xx\_responses\_use\_message) | Whether to use the query alert base message for HTTP 5xx responses monitor | `bool` | `false` | no |
| <a name="input_latency_enabled"></a> [latency\_enabled](#input\_latency\_enabled) | Enable latency monitor | `bool` | `false` | no |
| <a name="input_latency_evaluation_window"></a> [latency\_evaluation\_window](#input\_latency\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_latency_no_data_window"></a> [latency\_no\_data\_window](#input\_latency\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_latency_threshold_critical"></a> [latency\_threshold\_critical](#input\_latency\_threshold\_critical) | Critical threshold (seconds) | `number` | `null` | no |
| <a name="input_latency_threshold_warning"></a> [latency\_threshold\_warning](#input\_latency\_threshold\_warning) | Warning threshold (seconds) | `number` | `null` | no |
| <a name="input_latency_use_message"></a> [latency\_use\_message](#input\_latency\_use\_message) | Whether to use the query alert base message for latency monitor | `bool` | `false` | no |
| <a name="input_monitor_exclude_tags"></a> [monitor\_exclude\_tags](#input\_monitor\_exclude\_tags) | Tags to be excluded in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_monitor_include_tags"></a> [monitor\_include\_tags](#input\_monitor\_include\_tags) | Tags to be included in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_new_group_delay"></a> [new\_group\_delay](#input\_new\_group\_delay) | Delay in seconds before generating alerts for a new resource | `number` | `300` | no |
| <a name="input_no_healthy_instances_enabled"></a> [no\_healthy\_instances\_enabled](#input\_no\_healthy\_instances\_enabled) | Enable no healthy instances monitor | `bool` | `true` | no |
| <a name="input_no_healthy_instances_evaluation_window"></a> [no\_healthy\_instances\_evaluation\_window](#input\_no\_healthy\_instances\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_no_healthy_instances_no_data_window"></a> [no\_healthy\_instances\_no\_data\_window](#input\_no\_healthy\_instances\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_no_healthy_instances_threshold_critical"></a> [no\_healthy\_instances\_threshold\_critical](#input\_no\_healthy\_instances\_threshold\_critical) | Warning threshold (percentage) | `number` | `0` | no |
| <a name="input_no_healthy_instances_threshold_warning"></a> [no\_healthy\_instances\_threshold\_warning](#input\_no\_healthy\_instances\_threshold\_warning) | Warning threshold (percentage) | `number` | `null` | no |
| <a name="input_no_healthy_instances_use_message"></a> [no\_healthy\_instances\_use\_message](#input\_no\_healthy\_instances\_use\_message) | Whether to use the query alert base message for no healthy instances monitor | `bool` | `true` | no |
| <a name="input_notify_alert_override"></a> [notify\_alert\_override](#input\_notify\_alert\_override) | List of notifications for alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_crit_override"></a> [notify\_crit\_override](#input\_notify\_crit\_override) | List of notifications for 24x7 alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_default"></a> [notify\_default](#input\_notify\_default) | List of alert notifications (can be overridden based on alert type) | `list(string)` | n/a | yes |
| <a name="input_notify_no_data"></a> [notify\_no\_data](#input\_notify\_no\_data) | Alert if no matching data is found | `bool` | `false` | no |
| <a name="input_notify_nodata_override"></a> [notify\_nodata\_override](#input\_notify\_nodata\_override) | List of notifications for no data (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_nonprod_override"></a> [notify\_nonprod\_override](#input\_notify\_nonprod\_override) | List of notifications for non-prod alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_prod_override"></a> [notify\_prod\_override](#input\_notify\_prod\_override) | List of notifications for 12x5 prod alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_recovery_override"></a> [notify\_recovery\_override](#input\_notify\_recovery\_override) | List of notifications for alert recovery (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_warn_override"></a> [notify\_warn\_override](#input\_notify\_warn\_override) | List of notifications for alerts in warning threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_renotify_interval"></a> [renotify\_interval](#input\_renotify\_interval) | Interval in minutes to re-send notifications about an alert | `number` | `60` | no |
| <a name="input_runbook_link"></a> [runbook\_link](#input\_runbook\_link) | Runbook link to include in message | `string` | `null` | no |
| <a name="input_service"></a> [service](#input\_service) | Service associated with the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_team"></a> [team](#input\_team) | Team supporting the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_timeout_h"></a> [timeout\_h](#input\_timeout\_h) | Auto-resolve alert in specified hours if condition no longer matches | `number` | `0` | no |
| <a name="input_title_prefix"></a> [title\_prefix](#input\_title\_prefix) | Prefix all alerts with specified value in brackets | `string` | `null` | no |
| <a name="input_title_suffix"></a> [title\_suffix](#input\_title\_suffix) | Suffix all alerts with specified value in parenthesis | `string` | `null` | no |
| <a name="input_warn_priority"></a> [warn\_priority](#input\_warn\_priority) | Priority for alerts with no data (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
