# terraform-datadog-monitor/aws/elasticache

Configures the following for ElastiCache clusters based on tag matches:

* CPU utilization
* CPU utilization anomalous activity
* Cache hit rate
* Cache hit rate anomalous activity
* Evictions
* Max connections
* Memory utilization
* Swap usage

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
| [datadog_monitor.cpu_utilization](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.cpu_utilization_anomaly](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.evictions](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.hit_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.hit_rate_anomaly](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.max_connections](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.swap_usage](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:elasticache"<br>]</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_cpu_utilization_anomaly_deviations"></a> [cpu\_utilization\_anomaly\_deviations](#input\_cpu\_utilization\_anomaly\_deviations) | Standard deviations | `number` | `4` | no |
| <a name="input_cpu_utilization_anomaly_enabled"></a> [cpu\_utilization\_anomaly\_enabled](#input\_cpu\_utilization\_anomaly\_enabled) | Enable CPU utilization anomaly monitor | `bool` | `false` | no |
| <a name="input_cpu_utilization_anomaly_evaluation_window"></a> [cpu\_utilization\_anomaly\_evaluation\_window](#input\_cpu\_utilization\_anomaly\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_1h"` | no |
| <a name="input_cpu_utilization_anomaly_no_data_window"></a> [cpu\_utilization\_anomaly\_no\_data\_window](#input\_cpu\_utilization\_anomaly\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_utilization_anomaly_recovery_window"></a> [cpu\_utilization\_anomaly\_recovery\_window](#input\_cpu\_utilization\_anomaly\_recovery\_window) | Recovery window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cpu_utilization_anomaly_rollup"></a> [cpu\_utilization\_anomaly\_rollup](#input\_cpu\_utilization\_anomaly\_rollup) | Rollup interval (must be sized based on evaluation window/span and seasonaility) | `number` | `60` | no |
| <a name="input_cpu_utilization_anomaly_seasonality"></a> [cpu\_utilization\_anomaly\_seasonality](#input\_cpu\_utilization\_anomaly\_seasonality) | Seasonaility (hourly, daily, weekly) | `string` | `"weekly"` | no |
| <a name="input_cpu_utilization_anomaly_threshold_critical"></a> [cpu\_utilization\_anomaly\_threshold\_critical](#input\_cpu\_utilization\_anomaly\_threshold\_critical) | Critical threshold (percent) | `number` | `null` | no |
| <a name="input_cpu_utilization_anomaly_threshold_warning"></a> [cpu\_utilization\_anomaly\_threshold\_warning](#input\_cpu\_utilization\_anomaly\_threshold\_warning) | Warning threshold (percent) | `number` | `null` | no |
| <a name="input_cpu_utilization_anomaly_trigger_window"></a> [cpu\_utilization\_anomaly\_trigger\_window](#input\_cpu\_utilization\_anomaly\_trigger\_window) | Trigger window for anomaly monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_1h"` | no |
| <a name="input_cpu_utilization_enabled"></a> [cpu\_utilization\_enabled](#input\_cpu\_utilization\_enabled) | Enable CPU utilization monitor | `bool` | `false` | no |
| <a name="input_cpu_utilization_evaluation_window"></a> [cpu\_utilization\_evaluation\_window](#input\_cpu\_utilization\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_cpu_utilization_no_data_window"></a> [cpu\_utilization\_no\_data\_window](#input\_cpu\_utilization\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_utilization_threshold_critical"></a> [cpu\_utilization\_threshold\_critical](#input\_cpu\_utilization\_threshold\_critical) | Critical threshold (percent) | `number` | `90` | no |
| <a name="input_cpu_utilization_threshold_warning"></a> [cpu\_utilization\_threshold\_warning](#input\_cpu\_utilization\_threshold\_warning) | Warning threshold (percent) | `number` | `80` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | n/a | yes |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_evictions_enabled"></a> [evictions\_enabled](#input\_evictions\_enabled) | Enable eviction rate monitor | `bool` | `false` | no |
| <a name="input_evictions_evaluation_window"></a> [evictions\_evaluation\_window](#input\_evictions\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_evictions_no_data_window"></a> [evictions\_no\_data\_window](#input\_evictions\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_evictions_threshold_critical"></a> [evictions\_threshold\_critical](#input\_evictions\_threshold\_critical) | Critical threshold (count) | `number` | `null` | no |
| <a name="input_evictions_threshold_warning"></a> [evictions\_threshold\_warning](#input\_evictions\_threshold\_warning) | Warning threshold (count) | `number` | `null` | no |
| <a name="input_hit_rate_anomaly_deviations"></a> [hit\_rate\_anomaly\_deviations](#input\_hit\_rate\_anomaly\_deviations) | Standard deviations | `number` | `2` | no |
| <a name="input_hit_rate_anomaly_enabled"></a> [hit\_rate\_anomaly\_enabled](#input\_hit\_rate\_anomaly\_enabled) | Enable cache hit rate anomaly monitor | `bool` | `false` | no |
| <a name="input_hit_rate_anomaly_evaluation_window"></a> [hit\_rate\_anomaly\_evaluation\_window](#input\_hit\_rate\_anomaly\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_1h"` | no |
| <a name="input_hit_rate_anomaly_no_data_window"></a> [hit\_rate\_anomaly\_no\_data\_window](#input\_hit\_rate\_anomaly\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_hit_rate_anomaly_seasonality"></a> [hit\_rate\_anomaly\_seasonality](#input\_hit\_rate\_anomaly\_seasonality) | Seasonaility (hourly, daily, weekly) | `string` | `"daily"` | no |
| <a name="input_hit_rate_anomaly_threshold_critical"></a> [hit\_rate\_anomaly\_threshold\_critical](#input\_hit\_rate\_anomaly\_threshold\_critical) | Critical threshold (percentage) | `number` | `null` | no |
| <a name="input_hit_rate_enabled"></a> [hit\_rate\_enabled](#input\_hit\_rate\_enabled) | Enable cache hit rate monitor | `bool` | `false` | no |
| <a name="input_hit_rate_evaluation_window"></a> [hit\_rate\_evaluation\_window](#input\_hit\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_hit_rate_no_data_window"></a> [hit\_rate\_no\_data\_window](#input\_hit\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_hit_rate_threshold_critical"></a> [hit\_rate\_threshold\_critical](#input\_hit\_rate\_threshold\_critical) | Critical threshold (percentage) | `number` | `null` | no |
| <a name="input_hit_rate_threshold_warning"></a> [hit\_rate\_threshold\_warning](#input\_hit\_rate\_threshold\_warning) | Warning threshold (percentage) | `number` | `null` | no |
| <a name="input_max_connections_enabled"></a> [max\_connections\_enabled](#input\_max\_connections\_enabled) | Enable max connections monitor | `bool` | `false` | no |
| <a name="input_max_connections_evaluation_window"></a> [max\_connections\_evaluation\_window](#input\_max\_connections\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_max_connections_no_data_window"></a> [max\_connections\_no\_data\_window](#input\_max\_connections\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_max_connections_threshold_critical"></a> [max\_connections\_threshold\_critical](#input\_max\_connections\_threshold\_critical) | Critical threshold (connections) | `number` | `64000` | no |
| <a name="input_max_connections_threshold_warning"></a> [max\_connections\_threshold\_warning](#input\_max\_connections\_threshold\_warning) | Warning threshold (connections) | `number` | `60000` | no |
| <a name="input_monitor_exclude_tags"></a> [monitor\_exclude\_tags](#input\_monitor\_exclude\_tags) | Tags to be excluded in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_monitor_include_tags"></a> [monitor\_include\_tags](#input\_monitor\_include\_tags) | Tags to be included in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_new_group_delay"></a> [new\_group\_delay](#input\_new\_group\_delay) | Delay in seconds before generating alerts for a new resource | `number` | `300` | no |
| <a name="input_notify_alert_override"></a> [notify\_alert\_override](#input\_notify\_alert\_override) | List of notifications for alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_default"></a> [notify\_default](#input\_notify\_default) | List of alert notifications (can be overridden based on alert type) | `list(string)` | n/a | yes |
| <a name="input_notify_no_data"></a> [notify\_no\_data](#input\_notify\_no\_data) | Alert if no matching data is found | `bool` | `false` | no |
| <a name="input_notify_nodata_override"></a> [notify\_nodata\_override](#input\_notify\_nodata\_override) | List of notifications for no data (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_recovery_override"></a> [notify\_recovery\_override](#input\_notify\_recovery\_override) | List of notifications for alert recovery (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_warn_override"></a> [notify\_warn\_override](#input\_notify\_warn\_override) | List of notifications for alerts in warning threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_renotify_interval"></a> [renotify\_interval](#input\_renotify\_interval) | Interval in minutes to re-send notifications about an alert | `number` | `0` | no |
| <a name="input_runbook_link"></a> [runbook\_link](#input\_runbook\_link) | Runbook link to include in message | `string` | `null` | no |
| <a name="input_service"></a> [service](#input\_service) | Service associated with the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_swap_usage_enabled"></a> [swap\_usage\_enabled](#input\_swap\_usage\_enabled) | Enable swap usage monitor | `bool` | `false` | no |
| <a name="input_swap_usage_evaluation_window"></a> [swap\_usage\_evaluation\_window](#input\_swap\_usage\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_swap_usage_no_data_window"></a> [swap\_usage\_no\_data\_window](#input\_swap\_usage\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_swap_usage_threshold_critical"></a> [swap\_usage\_threshold\_critical](#input\_swap\_usage\_threshold\_critical) | Critical threshold (bytes) | `number` | `52428800` | no |
| <a name="input_swap_usage_threshold_warning"></a> [swap\_usage\_threshold\_warning](#input\_swap\_usage\_threshold\_warning) | Warning threshold (bytes) | `number` | `null` | no |
| <a name="input_team"></a> [team](#input\_team) | Team supporting the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_timeout_h"></a> [timeout\_h](#input\_timeout\_h) | Auto-resolve alert in specified hours if condition no longer matches | `number` | `0` | no |
| <a name="input_title_prefix"></a> [title\_prefix](#input\_title\_prefix) | Prefix all alerts with specified value in brackets | `string` | `null` | no |
| <a name="input_title_suffix"></a> [title\_suffix](#input\_title\_suffix) | Suffix all alerts with specified value in parenthesis | `string` | `null` | no |
| <a name="input_warn_priority"></a> [warn\_priority](#input\_warn\_priority) | Priority for alerts with no data (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
