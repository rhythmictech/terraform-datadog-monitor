# terraform-datadog-monitor/host/disk

Configures monitor for host disk space (forecast and actual) and disk inodes.

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
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 3.39.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_monitor.disk_inodes](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.disk_space](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.disk_space_forecast](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br/>  "resource:ec2"<br/>]</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_disk_inodes_enabled"></a> [disk\_inodes\_enabled](#input\_disk\_inodes\_enabled) | Flag to enable Free disk inodes monitor | `string` | `"true"` | no |
| <a name="input_disk_inodes_threshold_critical"></a> [disk\_inodes\_threshold\_critical](#input\_disk\_inodes\_threshold\_critical) | Free disk space critical threshold | `number` | `95` | no |
| <a name="input_disk_inodes_threshold_warning"></a> [disk\_inodes\_threshold\_warning](#input\_disk\_inodes\_threshold\_warning) | Free disk space warning threshold | `number` | `90` | no |
| <a name="input_disk_inodes_time_aggregator"></a> [disk\_inodes\_time\_aggregator](#input\_disk\_inodes\_time\_aggregator) | Monitor aggregator for Free disk inodes [available values: min, max or avg] | `string` | `"min"` | no |
| <a name="input_disk_inodes_timeframe"></a> [disk\_inodes\_timeframe](#input\_disk\_inodes\_timeframe) | Monitor timeframe for Free disk inodes [available values: `last_#m` (1, 5, 10, 15, or 30), `last_#h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_disk_inodes_use_message"></a> [disk\_inodes\_use\_message](#input\_disk\_inodes\_use\_message) | Flag to enable Free disk inodes alerting | `string` | `"true"` | no |
| <a name="input_disk_space_enabled"></a> [disk\_space\_enabled](#input\_disk\_space\_enabled) | Flag to enable Free diskspace monitor | `string` | `"true"` | no |
| <a name="input_disk_space_forecast_algorithm"></a> [disk\_space\_forecast\_algorithm](#input\_disk\_space\_forecast\_algorithm) | Algorithm for the Free diskspace Forecast monitor [available values: `linear` or `seasonal`] | `string` | `"linear"` | no |
| <a name="input_disk_space_forecast_deviations"></a> [disk\_space\_forecast\_deviations](#input\_disk\_space\_forecast\_deviations) | Deviations for the Free diskspace Forecast monitor [available values: `1`, `2`, `3`, `4` or `5`] | `string` | `1` | no |
| <a name="input_disk_space_forecast_enabled"></a> [disk\_space\_forecast\_enabled](#input\_disk\_space\_forecast\_enabled) | Flag to enable Free diskspace forecast monitor | `string` | `"true"` | no |
| <a name="input_disk_space_forecast_interval"></a> [disk\_space\_forecast\_interval](#input\_disk\_space\_forecast\_interval) | Interval for the Free diskspace Forecast monitor [available values: `30m`, `60m` or `120m`] | `string` | `"60m"` | no |
| <a name="input_disk_space_forecast_linear_history"></a> [disk\_space\_forecast\_linear\_history](#input\_disk\_space\_forecast\_linear\_history) | History for the Free diskspace Forecast monitor [available values: `12h`, `#d` (1, 2, or 3), `#w` (1, or 2) or `#mo` (1, 2 or 3)] | `string` | `"1w"` | no |
| <a name="input_disk_space_forecast_linear_model"></a> [disk\_space\_forecast\_linear\_model](#input\_disk\_space\_forecast\_linear\_model) | Model for the Free diskspace Forecast monitor [available values: `default`, `simple` or `reactive`] | `string` | `"default"` | no |
| <a name="input_disk_space_forecast_seasonal_seasonality"></a> [disk\_space\_forecast\_seasonal\_seasonality](#input\_disk\_space\_forecast\_seasonal\_seasonality) | Seasonality for the Free diskspace Forecast monitor | `string` | `"weekly"` | no |
| <a name="input_disk_space_forecast_threshold_critical"></a> [disk\_space\_forecast\_threshold\_critical](#input\_disk\_space\_forecast\_threshold\_critical) | Free disk space forecast critical threshold | `number` | `80` | no |
| <a name="input_disk_space_forecast_threshold_critical_recovery"></a> [disk\_space\_forecast\_threshold\_critical\_recovery](#input\_disk\_space\_forecast\_threshold\_critical\_recovery) | Free disk space forecast recovery threshold | `number` | `72` | no |
| <a name="input_disk_space_forecast_time_aggregator"></a> [disk\_space\_forecast\_time\_aggregator](#input\_disk\_space\_forecast\_time\_aggregator) | Monitor aggregator for Free diskspace forecast [available values: min, max or avg] | `string` | `"max"` | no |
| <a name="input_disk_space_forecast_timeframe"></a> [disk\_space\_forecast\_timeframe](#input\_disk\_space\_forecast\_timeframe) | Monitor timeframe for Free diskspace forecast [available values: `next_12h`, `next_#d` (1, 2, or 3), `next_#w` (1 or 2) or `next_#mo` (1, 2 or 3)] | `string` | `"next_1w"` | no |
| <a name="input_disk_space_forecast_use_message"></a> [disk\_space\_forecast\_use\_message](#input\_disk\_space\_forecast\_use\_message) | Flag to enable Free diskspace forecast alerting | `string` | `"false"` | no |
| <a name="input_disk_space_threshold_critical"></a> [disk\_space\_threshold\_critical](#input\_disk\_space\_threshold\_critical) | Free disk space critical threshold | `number` | `90` | no |
| <a name="input_disk_space_threshold_warning"></a> [disk\_space\_threshold\_warning](#input\_disk\_space\_threshold\_warning) | Free disk space warning threshold | `number` | `80` | no |
| <a name="input_disk_space_time_aggregator"></a> [disk\_space\_time\_aggregator](#input\_disk\_space\_time\_aggregator) | Monitor aggregator for Free diskspace [available values: min, max or avg] | `string` | `"max"` | no |
| <a name="input_disk_space_timeframe"></a> [disk\_space\_timeframe](#input\_disk\_space\_timeframe) | Monitor timeframe for Free diskspace [available values: `last_#m` (1, 5, 10, 15, or 30), `last_#h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_disk_space_use_message"></a> [disk\_space\_use\_message](#input\_disk\_space\_use\_message) | Flag to enable Free diskspace alerting | `string` | `"true"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br/>  "name",<br/>  "aws_account",<br/>  "env",<br/>  "datadog_managed"<br/>]</pre> | no |
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
