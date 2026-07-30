# terraform-datadog-monitor/azure/app-service-plan

Configures monitors for Azure App Service **Plans** (`azure.web_serverfarms.*`), the shared compute
unit that App Service sites and Function Apps run on.

Pair with `azure/app-service` (per-site request and latency signals) and `azure/functions`.

## Running the tests

Unit tests live in `tests/` and assert monitor toggles, metric namespaces, group-by tags, threshold
plumbing, and tag composition against a mocked Datadog provider (no API access needed).

```bash
terraform init -backend=false
terraform test
```

They use `mock_provider`, which requires Terraform >= 1.7; the repo's `.terraform-version` pins
`latest:^1.9`, so a `tfenv install` gives you a compatible binary.

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
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_monitor.cpu_percentage](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.disk_queue_length](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.http_queue_length](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.memory_percentage](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:app-service-plan"<br>]</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_cpu_percentage_enabled"></a> [cpu\_percentage\_enabled](#input\_cpu\_percentage\_enabled) | Enable App Service Plan CPU utilization monitor | `bool` | `true` | no |
| <a name="input_cpu_percentage_evaluation_window"></a> [cpu\_percentage\_evaluation\_window](#input\_cpu\_percentage\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cpu_percentage_no_data_window"></a> [cpu\_percentage\_no\_data\_window](#input\_cpu\_percentage\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_percentage_threshold_critical"></a> [cpu\_percentage\_threshold\_critical](#input\_cpu\_percentage\_threshold\_critical) | Plan CPU utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_cpu_percentage_threshold_warning"></a> [cpu\_percentage\_threshold\_warning](#input\_cpu\_percentage\_threshold\_warning) | Plan CPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_cpu_percentage_use_message"></a> [cpu\_percentage\_use\_message](#input\_cpu\_percentage\_use\_message) | Whether to use the query alert base message for App Service Plan CPU utilization monitor | `bool` | `false` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_disk_queue_length_enabled"></a> [disk\_queue\_length\_enabled](#input\_disk\_queue\_length\_enabled) | Enable App Service Plan disk queue length monitor (disabled by default; only meaningful for storage-heavy plans) | `bool` | `false` | no |
| <a name="input_disk_queue_length_evaluation_window"></a> [disk\_queue\_length\_evaluation\_window](#input\_disk\_queue\_length\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_disk_queue_length_no_data_window"></a> [disk\_queue\_length\_no\_data\_window](#input\_disk\_queue\_length\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_disk_queue_length_threshold_critical"></a> [disk\_queue\_length\_threshold\_critical](#input\_disk\_queue\_length\_threshold\_critical) | Disk queue length at which to alert critical | `number` | `100` | no |
| <a name="input_disk_queue_length_threshold_warning"></a> [disk\_queue\_length\_threshold\_warning](#input\_disk\_queue\_length\_threshold\_warning) | Disk queue length at which to alert warning | `number` | `25` | no |
| <a name="input_disk_queue_length_use_message"></a> [disk\_queue\_length\_use\_message](#input\_disk\_queue\_length\_use\_message) | Whether to use the query alert base message for App Service Plan disk queue length monitor | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br>  "name",<br>  "aws_account",<br>  "env",<br>  "datadog_managed"<br>]</pre> | no |
| <a name="input_http_queue_length_enabled"></a> [http\_queue\_length\_enabled](#input\_http\_queue\_length\_enabled) | Enable App Service Plan HTTP queue length monitor | `bool` | `true` | no |
| <a name="input_http_queue_length_evaluation_window"></a> [http\_queue\_length\_evaluation\_window](#input\_http\_queue\_length\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_http_queue_length_no_data_window"></a> [http\_queue\_length\_no\_data\_window](#input\_http\_queue\_length\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_http_queue_length_threshold_critical"></a> [http\_queue\_length\_threshold\_critical](#input\_http\_queue\_length\_threshold\_critical) | Number of queued HTTP requests at which to alert critical | `number` | `100` | no |
| <a name="input_http_queue_length_threshold_warning"></a> [http\_queue\_length\_threshold\_warning](#input\_http\_queue\_length\_threshold\_warning) | Number of queued HTTP requests at which to alert warning | `number` | `25` | no |
| <a name="input_http_queue_length_use_message"></a> [http\_queue\_length\_use\_message](#input\_http\_queue\_length\_use\_message) | Whether to use the query alert base message for App Service Plan HTTP queue length monitor | `bool` | `false` | no |
| <a name="input_memory_percentage_enabled"></a> [memory\_percentage\_enabled](#input\_memory\_percentage\_enabled) | Enable App Service Plan memory utilization monitor | `bool` | `true` | no |
| <a name="input_memory_percentage_evaluation_window"></a> [memory\_percentage\_evaluation\_window](#input\_memory\_percentage\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_memory_percentage_no_data_window"></a> [memory\_percentage\_no\_data\_window](#input\_memory\_percentage\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_memory_percentage_threshold_critical"></a> [memory\_percentage\_threshold\_critical](#input\_memory\_percentage\_threshold\_critical) | Plan memory utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_memory_percentage_threshold_warning"></a> [memory\_percentage\_threshold\_warning](#input\_memory\_percentage\_threshold\_warning) | Plan memory utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_memory_percentage_use_message"></a> [memory\_percentage\_use\_message](#input\_memory\_percentage\_use\_message) | Whether to use the query alert base message for App Service Plan memory utilization monitor | `bool` | `false` | no |
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
