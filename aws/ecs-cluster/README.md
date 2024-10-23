# terraform-datadog-monitor/aws/ecs-cluster

Configures the following for ECS clusters based on tags matches:

* ECS agent status
* cluster cpu utilization
* cluster memory reservation

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
| [datadog_monitor.agent_status](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.cpu_utilization](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.cpu_utilization_anomaly](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.memory_reservation](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_agent_status_enabled"></a> [agent\_status\_enabled](#input\_agent\_status\_enabled) | Enable agent status monitor | `bool` | `false` | no |
| <a name="input_agent_status_evaluation_window"></a> [agent\_status\_evaluation\_window](#input\_agent\_status\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_agent_status_no_data_window"></a> [agent\_status\_no\_data\_window](#input\_agent\_status\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_agent_status_threshold_critical"></a> [agent\_status\_threshold\_critical](#input\_agent\_status\_threshold\_critical) | Critical threshold | `number` | `5` | no |
| <a name="input_agent_status_threshold_warning"></a> [agent\_status\_threshold\_warning](#input\_agent\_status\_threshold\_warning) | Warning threshold | `number` | `3` | no |
| <a name="input_agent_status_use_message"></a> [agent\_status\_use\_message](#input\_agent\_status\_use\_message) | Whether to use the query alert base message for agent status monitor | `bool` | `false` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:ecs-cluster"<br>]</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_cpu_utilization_anomaly_deviations"></a> [cpu\_utilization\_anomaly\_deviations](#input\_cpu\_utilization\_anomaly\_deviations) | Standard deviations | `number` | `3` | no |
| <a name="input_cpu_utilization_anomaly_enabled"></a> [cpu\_utilization\_anomaly\_enabled](#input\_cpu\_utilization\_anomaly\_enabled) | Enable cache hit rate anomaly monitor | `bool` | `false` | no |
| <a name="input_cpu_utilization_anomaly_evaluation_window"></a> [cpu\_utilization\_anomaly\_evaluation\_window](#input\_cpu\_utilization\_anomaly\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_1d"` | no |
| <a name="input_cpu_utilization_anomaly_no_data_window"></a> [cpu\_utilization\_anomaly\_no\_data\_window](#input\_cpu\_utilization\_anomaly\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_utilization_anomaly_recovery_window"></a> [cpu\_utilization\_anomaly\_recovery\_window](#input\_cpu\_utilization\_anomaly\_recovery\_window) | Recovery window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cpu_utilization_anomaly_rollup"></a> [cpu\_utilization\_anomaly\_rollup](#input\_cpu\_utilization\_anomaly\_rollup) | Rollup interval (must be sized based on evaluation window/span and seasonaility) | `number` | `60` | no |
| <a name="input_cpu_utilization_anomaly_seasonality"></a> [cpu\_utilization\_anomaly\_seasonality](#input\_cpu\_utilization\_anomaly\_seasonality) | Seasonaility (hourly, daily, weekly) | `string` | `"weekly"` | no |
| <a name="input_cpu_utilization_anomaly_threshold_critical"></a> [cpu\_utilization\_anomaly\_threshold\_critical](#input\_cpu\_utilization\_anomaly\_threshold\_critical) | Critical threshold (percent) | `number` | `null` | no |
| <a name="input_cpu_utilization_anomaly_threshold_warning"></a> [cpu\_utilization\_anomaly\_threshold\_warning](#input\_cpu\_utilization\_anomaly\_threshold\_warning) | Warning threshold (percent) | `number` | `null` | no |
| <a name="input_cpu_utilization_anomaly_trigger_window"></a> [cpu\_utilization\_anomaly\_trigger\_window](#input\_cpu\_utilization\_anomaly\_trigger\_window) | Trigger window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_1h"` | no |
| <a name="input_cpu_utilization_anomaly_use_message"></a> [cpu\_utilization\_anomaly\_use\_message](#input\_cpu\_utilization\_anomaly\_use\_message) | Whether to use the query alert base message for CPU utilization anomaly monitor | `bool` | `false` | no |
| <a name="input_cpu_utilization_enabled"></a> [cpu\_utilization\_enabled](#input\_cpu\_utilization\_enabled) | Enable cluster CPU utilization monitor | `bool` | `false` | no |
| <a name="input_cpu_utilization_evaluation_window"></a> [cpu\_utilization\_evaluation\_window](#input\_cpu\_utilization\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_cpu_utilization_no_data_window"></a> [cpu\_utilization\_no\_data\_window](#input\_cpu\_utilization\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_utilization_threshold_critical"></a> [cpu\_utilization\_threshold\_critical](#input\_cpu\_utilization\_threshold\_critical) | Critical threshold (percent) | `number` | `90` | no |
| <a name="input_cpu_utilization_threshold_warning"></a> [cpu\_utilization\_threshold\_warning](#input\_cpu\_utilization\_threshold\_warning) | Warning threshold (percent) | `number` | `80` | no |
| <a name="input_cpu_utilization_use_message"></a> [cpu\_utilization\_use\_message](#input\_cpu\_utilization\_use\_message) | Whether to use the query alert base message for CPU utilization monitor | `bool` | `false` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_memory_reservation_enabled"></a> [memory\_reservation\_enabled](#input\_memory\_reservation\_enabled) | Enable cluster memory reservation monitor | `bool` | `false` | no |
| <a name="input_memory_reservation_evaluation_window"></a> [memory\_reservation\_evaluation\_window](#input\_memory\_reservation\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_memory_reservation_no_data_window"></a> [memory\_reservation\_no\_data\_window](#input\_memory\_reservation\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_memory_reservation_threshold_critical"></a> [memory\_reservation\_threshold\_critical](#input\_memory\_reservation\_threshold\_critical) | Critical threshold (percent) | `number` | `90` | no |
| <a name="input_memory_reservation_threshold_warning"></a> [memory\_reservation\_threshold\_warning](#input\_memory\_reservation\_threshold\_warning) | Warning threshold (percent) | `number` | `80` | no |
| <a name="input_memory_reservation_use_message"></a> [memory\_reservation\_use\_message](#input\_memory\_reservation\_use\_message) | Whether to use the query alert base message for memory reservation monitor | `bool` | `false` | no |
| <a name="input_monitor_exclude_tags"></a> [monitor\_exclude\_tags](#input\_monitor\_exclude\_tags) | Tags to be excluded in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_monitor_include_tags"></a> [monitor\_include\_tags](#input\_monitor\_include\_tags) | Tags to be included in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_new_group_delay"></a> [new\_group\_delay](#input\_new\_group\_delay) | Delay in seconds before generating alerts for a new resource | `number` | `300` | no |
| <a name="input_notify_alert_override"></a> [notify\_alert\_override](#input\_notify\_alert\_override) | List of notifications for alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_crit_override"></a> [notify\_crit\_override](#input\_notify\_crit\_override) | List of notifications for 24x7 alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_default"></a> [notify\_default](#input\_notify\_default) | List of alert notifications (can be overridden based on alert type) | `list(string)` | n/a | yes |
| <a name="input_notify_no_data"></a> [notify\_no\_data](#input\_notify\_no\_data) | Alert if no matching data is found | `bool` | `false` | no |
| <a name="input_notify_nodata_override"></a> [notify\_nodata\_override](#input\_notify\_nodata\_override) | List of notifications for no data (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_nonprod_override"></a> [notify\_nonprod\_override](#input\_notify\_nonprod\_override) | List of notifications for non-prod alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_prod_override"></a> [notify\_prod\_override](#input\_notify\_prod\_override) | List of notifications for 12x5 prod alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_recovery_override"></a> [notify\_recovery\_override](#input\_notify\_recovery\_override) | List of notifications for alert recovery (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_warn_override"></a> [notify\_warn\_override](#input\_notify\_warn\_override) | List of notifications for alerts in warning threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_renotify_interval"></a> [renotify\_interval](#input\_renotify\_interval) | Interval in minutes to re-send notifications about an alert | `number` | `0` | no |
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
