# terraform-datadog-monitor/aws/lambda

Configures the following for Lambda functions based on tag matches:

* cold starts (requires enhanced metrics)
* iterator age (requires enhanced metrics)
* iterator age forecast (stream data loss, requires enhanced metrics)
* error rate
* out of memory
* throttle rate
* timeouts

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
| [datadog_monitor.cold_starts](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.error_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.iterator_age](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.iterator_age_forecast](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.out_of_memory](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.throttle_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.timeouts](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:lambda"<br>]</pre> | no |
| <a name="input_cold_starts_enabled"></a> [cold\_starts\_enabled](#input\_cold\_starts\_enabled) | Enable cold starts monitor (requires enhanced metrics) | `bool` | `false` | no |
| <a name="input_cold_starts_evaluation_window"></a> [cold\_starts\_evaluation\_window](#input\_cold\_starts\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_4h"` | no |
| <a name="input_cold_starts_no_data_window"></a> [cold\_starts\_no\_data\_window](#input\_cold\_starts\_no\_data\_window) | No data threshold (in minutes, null to disable) | `number` | `null` | no |
| <a name="input_cold_starts_threshold_critical"></a> [cold\_starts\_threshold\_critical](#input\_cold\_starts\_threshold\_critical) | Critical threshold (count) | `number` | `null` | no |
| <a name="input_cold_starts_threshold_warning"></a> [cold\_starts\_threshold\_warning](#input\_cold\_starts\_threshold\_warning) | Warning threshold (count) | `number` | `null` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | n/a | yes |
| <a name="input_error_rate_enabled"></a> [error\_rate\_enabled](#input\_error\_rate\_enabled) | Enable Lambda error rate monitor | `bool` | `false` | no |
| <a name="input_error_rate_evaluation_window"></a> [error\_rate\_evaluation\_window](#input\_error\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_error_rate_no_data_window"></a> [error\_rate\_no\_data\_window](#input\_error\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_error_rate_threshold_critical"></a> [error\_rate\_threshold\_critical](#input\_error\_rate\_threshold\_critical) | Critical threshold (percentage, 0-100) | `number` | `75` | no |
| <a name="input_error_rate_threshold_warning"></a> [error\_rate\_threshold\_warning](#input\_error\_rate\_threshold\_warning) | Warning threshold (percentage, 0-100) | `number` | `25` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_iterator_age_enabled"></a> [iterator\_age\_enabled](#input\_iterator\_age\_enabled) | Enable iterator age monitor | `bool` | `false` | no |
| <a name="input_iterator_age_evaluation_window"></a> [iterator\_age\_evaluation\_window](#input\_iterator\_age\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_1h"` | no |
| <a name="input_iterator_age_forecast_enabled"></a> [iterator\_age\_forecast\_enabled](#input\_iterator\_age\_forecast\_enabled) | Enable iterator age monitor | `bool` | `false` | no |
| <a name="input_iterator_age_forecast_evaluation_window"></a> [iterator\_age\_forecast\_evaluation\_window](#input\_iterator\_age\_forecast\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_1d"` | no |
| <a name="input_iterator_age_forecast_no_data_window"></a> [iterator\_age\_forecast\_no\_data\_window](#input\_iterator\_age\_forecast\_no\_data\_window) | No data threshold (in minutes, null to disable) | `number` | `null` | no |
| <a name="input_iterator_age_no_data_window"></a> [iterator\_age\_no\_data\_window](#input\_iterator\_age\_no\_data\_window) | No data threshold (in minutes, null to disable) | `number` | `null` | no |
| <a name="input_iterator_age_threshold_critical"></a> [iterator\_age\_threshold\_critical](#input\_iterator\_age\_threshold\_critical) | Critical threshold (milliseconds) | `number` | `86400000` | no |
| <a name="input_iterator_age_threshold_warning"></a> [iterator\_age\_threshold\_warning](#input\_iterator\_age\_threshold\_warning) | Warning threshold (milliseconds) | `number` | `null` | no |
| <a name="input_monitor_exclude_tags"></a> [monitor\_exclude\_tags](#input\_monitor\_exclude\_tags) | Tags to be excluded in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_monitor_include_tags"></a> [monitor\_include\_tags](#input\_monitor\_include\_tags) | Tags to be included in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_new_group_delay"></a> [new\_group\_delay](#input\_new\_group\_delay) | Delay in seconds before generating alerts for a new resource | `number` | `300` | no |
| <a name="input_notify_alert_override"></a> [notify\_alert\_override](#input\_notify\_alert\_override) | List of notifications for alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_default"></a> [notify\_default](#input\_notify\_default) | List of alert notifications (can be overridden based on alert type) | `list(string)` | n/a | yes |
| <a name="input_notify_no_data"></a> [notify\_no\_data](#input\_notify\_no\_data) | Alert if no matching data is found | `bool` | `false` | no |
| <a name="input_notify_nodata_override"></a> [notify\_nodata\_override](#input\_notify\_nodata\_override) | List of notifications for no data (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_recovery_override"></a> [notify\_recovery\_override](#input\_notify\_recovery\_override) | List of notifications for alert recovery (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_warn_override"></a> [notify\_warn\_override](#input\_notify\_warn\_override) | List of notifications for alerts in warning threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_out_of_memory_enabled"></a> [out\_of\_memory\_enabled](#input\_out\_of\_memory\_enabled) | Enable out of memory monitor (requires enhanced metrics) | `bool` | `false` | no |
| <a name="input_out_of_memory_evaluation_window"></a> [out\_of\_memory\_evaluation\_window](#input\_out\_of\_memory\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_4h"` | no |
| <a name="input_out_of_memory_no_data_window"></a> [out\_of\_memory\_no\_data\_window](#input\_out\_of\_memory\_no\_data\_window) | No data threshold (in minutes, null to disable) | `number` | `null` | no |
| <a name="input_out_of_memory_threshold_critical"></a> [out\_of\_memory\_threshold\_critical](#input\_out\_of\_memory\_threshold\_critical) | Critical threshold (count) | `number` | `null` | no |
| <a name="input_out_of_memory_threshold_warning"></a> [out\_of\_memory\_threshold\_warning](#input\_out\_of\_memory\_threshold\_warning) | Warning threshold (count) | `number` | `null` | no |
| <a name="input_renotify_interval"></a> [renotify\_interval](#input\_renotify\_interval) | Interval in minutes to re-send notifications about an alert | `number` | `0` | no |
| <a name="input_runbook_link"></a> [runbook\_link](#input\_runbook\_link) | Runbook link to include in message | `string` | `null` | no |
| <a name="input_service"></a> [service](#input\_service) | Service associated with the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_team"></a> [team](#input\_team) | Team supporting the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_throttle_rate_enabled"></a> [throttle\_rate\_enabled](#input\_throttle\_rate\_enabled) | Enable Lambda throttle rate monitor | `bool` | `false` | no |
| <a name="input_throttle_rate_evaluation_window"></a> [throttle\_rate\_evaluation\_window](#input\_throttle\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_throttle_rate_no_data_window"></a> [throttle\_rate\_no\_data\_window](#input\_throttle\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_throttle_rate_threshold_critical"></a> [throttle\_rate\_threshold\_critical](#input\_throttle\_rate\_threshold\_critical) | Critical threshold (percentage, 0-100) | `number` | `75` | no |
| <a name="input_throttle_rate_threshold_warning"></a> [throttle\_rate\_threshold\_warning](#input\_throttle\_rate\_threshold\_warning) | Warning threshold (percentage, 0-100) | `number` | `25` | no |
| <a name="input_timeout_h"></a> [timeout\_h](#input\_timeout\_h) | Auto-resolve alert in specified hours if condition no longer matches | `number` | `0` | no |
| <a name="input_timeouts_enabled"></a> [timeouts\_enabled](#input\_timeouts\_enabled) | Enable timeout count monitor | `bool` | `false` | no |
| <a name="input_timeouts_evaluation_window"></a> [timeouts\_evaluation\_window](#input\_timeouts\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_timeouts_no_data_window"></a> [timeouts\_no\_data\_window](#input\_timeouts\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_timeouts_threshold_critical"></a> [timeouts\_threshold\_critical](#input\_timeouts\_threshold\_critical) | Critical threshold (count) | `number` | `75` | no |
| <a name="input_timeouts_threshold_warning"></a> [timeouts\_threshold\_warning](#input\_timeouts\_threshold\_warning) | Warning threshold (count) | `number` | `25` | no |
| <a name="input_title_prefix"></a> [title\_prefix](#input\_title\_prefix) | Prefix all alerts with specified value in brackets | `string` | `null` | no |
| <a name="input_title_suffix"></a> [title\_suffix](#input\_title\_suffix) | Suffix all alerts with specified value in parenthesis | `string` | `null` | no |
| <a name="input_warn_priority"></a> [warn\_priority](#input\_warn\_priority) | Priority for alerts with no data (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
