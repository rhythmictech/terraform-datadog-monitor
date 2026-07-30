# terraform-datadog-monitor/azure/service-bus

Configures monitors for Azure Service Bus namespaces (`azure.servicebus_namespaces.*`).

Defaults cover the signals that are actionable on any namespace: dead-lettered messages, server errors,
throttled requests, and message backlog. The `cpu` and `memory_usage` monitors are disabled by default
because those metrics are emitted only by **Premium** SKU namespaces.

> **Tuning:** thresholds are compared with `>`, so a threshold of `0` alerts on any occurrence.
> `dead_lettered_messages_threshold_critical` defaults to `10` (warning at any dead letter). For
> workloads where a single dead letter means a lost job, set the critical threshold to `0` as well.
> `active_messages_backlog_threshold_critical` is deliberately generous and should be tuned to the
> queue's normal depth.

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
| [datadog_monitor.active_messages_backlog](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.cpu](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.dead_lettered_messages](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.memory_usage](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.server_errors](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.throttled_requests](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.user_errors](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_messages_backlog_enabled"></a> [active\_messages\_backlog\_enabled](#input\_active\_messages\_backlog\_enabled) | Enable Service Bus active message backlog monitor | `bool` | `true` | no |
| <a name="input_active_messages_backlog_evaluation_window"></a> [active\_messages\_backlog\_evaluation\_window](#input\_active\_messages\_backlog\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_30m"` | no |
| <a name="input_active_messages_backlog_no_data_window"></a> [active\_messages\_backlog\_no\_data\_window](#input\_active\_messages\_backlog\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `30` | no |
| <a name="input_active_messages_backlog_threshold_critical"></a> [active\_messages\_backlog\_threshold\_critical](#input\_active\_messages\_backlog\_threshold\_critical) | Active message count at which to alert critical (tune per workload) | `number` | `1000` | no |
| <a name="input_active_messages_backlog_threshold_warning"></a> [active\_messages\_backlog\_threshold\_warning](#input\_active\_messages\_backlog\_threshold\_warning) | Active message count at which to alert warning (tune per workload) | `number` | `500` | no |
| <a name="input_active_messages_backlog_use_message"></a> [active\_messages\_backlog\_use\_message](#input\_active\_messages\_backlog\_use\_message) | Whether to use the query alert base message for Service Bus active message backlog monitor | `bool` | `false` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:service-bus"<br>]</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_cpu_enabled"></a> [cpu\_enabled](#input\_cpu\_enabled) | Enable Service Bus CPU monitor (disabled by default; emitted only by Premium SKU namespaces) | `bool` | `false` | no |
| <a name="input_cpu_evaluation_window"></a> [cpu\_evaluation\_window](#input\_cpu\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cpu_no_data_window"></a> [cpu\_no\_data\_window](#input\_cpu\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_threshold_critical"></a> [cpu\_threshold\_critical](#input\_cpu\_threshold\_critical) | Namespace CPU percentage at which to alert critical | `number` | `90` | no |
| <a name="input_cpu_threshold_warning"></a> [cpu\_threshold\_warning](#input\_cpu\_threshold\_warning) | Namespace CPU percentage at which to alert warning | `number` | `80` | no |
| <a name="input_cpu_use_message"></a> [cpu\_use\_message](#input\_cpu\_use\_message) | Whether to use the query alert base message for Service Bus CPU monitor | `bool` | `false` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_dead_lettered_messages_enabled"></a> [dead\_lettered\_messages\_enabled](#input\_dead\_lettered\_messages\_enabled) | Enable Service Bus dead-lettered message monitor | `bool` | `true` | no |
| <a name="input_dead_lettered_messages_evaluation_window"></a> [dead\_lettered\_messages\_evaluation\_window](#input\_dead\_lettered\_messages\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_dead_lettered_messages_no_data_window"></a> [dead\_lettered\_messages\_no\_data\_window](#input\_dead\_lettered\_messages\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_dead_lettered_messages_threshold_critical"></a> [dead\_lettered\_messages\_threshold\_critical](#input\_dead\_lettered\_messages\_threshold\_critical) | Dead-lettered message count above which to alert critical (set to 0 for workloads where any dead letter means a lost job) | `number` | `10` | no |
| <a name="input_dead_lettered_messages_threshold_warning"></a> [dead\_lettered\_messages\_threshold\_warning](#input\_dead\_lettered\_messages\_threshold\_warning) | Dead-lettered message count above which to alert warning (the default of 0 warns on any dead letter) | `number` | `0` | no |
| <a name="input_dead_lettered_messages_use_message"></a> [dead\_lettered\_messages\_use\_message](#input\_dead\_lettered\_messages\_use\_message) | Whether to use the query alert base message for Service Bus dead-lettered message monitor | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br>  "name",<br>  "aws_account",<br>  "env",<br>  "datadog_managed"<br>]</pre> | no |
| <a name="input_memory_usage_enabled"></a> [memory\_usage\_enabled](#input\_memory\_usage\_enabled) | Enable Service Bus memory monitor (disabled by default; emitted only by Premium SKU namespaces) | `bool` | `false` | no |
| <a name="input_memory_usage_evaluation_window"></a> [memory\_usage\_evaluation\_window](#input\_memory\_usage\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_memory_usage_no_data_window"></a> [memory\_usage\_no\_data\_window](#input\_memory\_usage\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_memory_usage_threshold_critical"></a> [memory\_usage\_threshold\_critical](#input\_memory\_usage\_threshold\_critical) | Namespace memory percentage at which to alert critical | `number` | `90` | no |
| <a name="input_memory_usage_threshold_warning"></a> [memory\_usage\_threshold\_warning](#input\_memory\_usage\_threshold\_warning) | Namespace memory percentage at which to alert warning | `number` | `80` | no |
| <a name="input_memory_usage_use_message"></a> [memory\_usage\_use\_message](#input\_memory\_usage\_use\_message) | Whether to use the query alert base message for Service Bus memory monitor | `bool` | `false` | no |
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
| <a name="input_server_errors_enabled"></a> [server\_errors\_enabled](#input\_server\_errors\_enabled) | Enable Service Bus server error monitor | `bool` | `true` | no |
| <a name="input_server_errors_evaluation_window"></a> [server\_errors\_evaluation\_window](#input\_server\_errors\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_server_errors_no_data_window"></a> [server\_errors\_no\_data\_window](#input\_server\_errors\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_server_errors_threshold_critical"></a> [server\_errors\_threshold\_critical](#input\_server\_errors\_threshold\_critical) | Server error count above which to alert critical (the default of 0 alerts on any server error in the evaluation window) | `number` | `0` | no |
| <a name="input_server_errors_use_message"></a> [server\_errors\_use\_message](#input\_server\_errors\_use\_message) | Whether to use the query alert base message for Service Bus server error monitor | `bool` | `false` | no |
| <a name="input_service"></a> [service](#input\_service) | Service associated with the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_team"></a> [team](#input\_team) | Team supporting the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_throttled_requests_enabled"></a> [throttled\_requests\_enabled](#input\_throttled\_requests\_enabled) | Enable Service Bus throttled request monitor | `bool` | `true` | no |
| <a name="input_throttled_requests_evaluation_window"></a> [throttled\_requests\_evaluation\_window](#input\_throttled\_requests\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_throttled_requests_no_data_window"></a> [throttled\_requests\_no\_data\_window](#input\_throttled\_requests\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_throttled_requests_threshold_critical"></a> [throttled\_requests\_threshold\_critical](#input\_throttled\_requests\_threshold\_critical) | Throttled request count at which to alert critical | `number` | `10` | no |
| <a name="input_throttled_requests_threshold_warning"></a> [throttled\_requests\_threshold\_warning](#input\_throttled\_requests\_threshold\_warning) | Throttled request count at which to alert warning | `number` | `1` | no |
| <a name="input_throttled_requests_use_message"></a> [throttled\_requests\_use\_message](#input\_throttled\_requests\_use\_message) | Whether to use the query alert base message for Service Bus throttled request monitor | `bool` | `false` | no |
| <a name="input_timeout_h"></a> [timeout\_h](#input\_timeout\_h) | Auto-resolve alert in specified hours if condition no longer matches | `number` | `0` | no |
| <a name="input_title_prefix"></a> [title\_prefix](#input\_title\_prefix) | Prefix all alerts with specified value in brackets | `string` | `null` | no |
| <a name="input_title_suffix"></a> [title\_suffix](#input\_title\_suffix) | Suffix all alerts with specified value in parenthesis | `string` | `null` | no |
| <a name="input_user_errors_enabled"></a> [user\_errors\_enabled](#input\_user\_errors\_enabled) | Enable Service Bus user error monitor (disabled by default; user errors are usually application-side and noisy) | `bool` | `false` | no |
| <a name="input_user_errors_evaluation_window"></a> [user\_errors\_evaluation\_window](#input\_user\_errors\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_user_errors_no_data_window"></a> [user\_errors\_no\_data\_window](#input\_user\_errors\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_user_errors_threshold_critical"></a> [user\_errors\_threshold\_critical](#input\_user\_errors\_threshold\_critical) | User error count at which to alert critical | `number` | `100` | no |
| <a name="input_user_errors_threshold_warning"></a> [user\_errors\_threshold\_warning](#input\_user\_errors\_threshold\_warning) | User error count at which to alert warning | `number` | `25` | no |
| <a name="input_user_errors_use_message"></a> [user\_errors\_use\_message](#input\_user\_errors\_use\_message) | Whether to use the query alert base message for Service Bus user error monitor | `bool` | `false` | no |
| <a name="input_warn_priority"></a> [warn\_priority](#input\_warn\_priority) | Priority for alerts with no data (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
