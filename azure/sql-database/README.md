# terraform-datadog-monitor/azure/sql-database

Configures monitors for **individual** Azure SQL databases (`azure.sql_servers_databases.*`).

Pair with `azure/sql-elastic-pool`. When databases are pooled, the pool is the shared capacity unit and
is where saturation actually surfaces, so the pool module carries the estate-wide signal while this one
carries the per-database signal.

## Purchasing models

`cpu_percent` is valid under both the vCore and DTU purchasing models and is the enabled-by-default
saturation signal. `dtu_consumption_percent` is emitted **only** under the DTU model, so it ships
disabled: on a vCore database it would sit permanently in no-data. Enable
`dtu_consumption_high_enabled` only for DTU-model databases.

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
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 4.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_monitor.connection_failures](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.cpu_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.deadlocks](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.dtu_consumption_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.log_write_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.sessions_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.storage_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.workers_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:sql-database"<br>]</pre> | no |
| <a name="input_connection_failures_enabled"></a> [connection\_failures\_enabled](#input\_connection\_failures\_enabled) | Enable SQL Database failed connection monitor | `bool` | `true` | no |
| <a name="input_connection_failures_evaluation_window"></a> [connection\_failures\_evaluation\_window](#input\_connection\_failures\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_connection_failures_no_data_window"></a> [connection\_failures\_no\_data\_window](#input\_connection\_failures\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_connection_failures_threshold_critical"></a> [connection\_failures\_threshold\_critical](#input\_connection\_failures\_threshold\_critical) | Number of failed connections in the evaluation window at which to alert critical | `number` | `10` | no |
| <a name="input_connection_failures_threshold_warning"></a> [connection\_failures\_threshold\_warning](#input\_connection\_failures\_threshold\_warning) | Number of failed connections in the evaluation window at which to alert warning | `number` | `1` | no |
| <a name="input_connection_failures_use_message"></a> [connection\_failures\_use\_message](#input\_connection\_failures\_use\_message) | Whether to use the query alert base message for SQL Database failed connection monitor | `bool` | `false` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_cpu_high_enabled"></a> [cpu\_high\_enabled](#input\_cpu\_high\_enabled) | Enable SQL Database CPU utilization monitor | `bool` | `true` | no |
| <a name="input_cpu_high_evaluation_window"></a> [cpu\_high\_evaluation\_window](#input\_cpu\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cpu_high_no_data_window"></a> [cpu\_high\_no\_data\_window](#input\_cpu\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_high_threshold_critical"></a> [cpu\_high\_threshold\_critical](#input\_cpu\_high\_threshold\_critical) | Database CPU utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_cpu_high_threshold_warning"></a> [cpu\_high\_threshold\_warning](#input\_cpu\_high\_threshold\_warning) | Database CPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_cpu_high_use_message"></a> [cpu\_high\_use\_message](#input\_cpu\_high\_use\_message) | Whether to use the query alert base message for SQL Database CPU utilization monitor | `bool` | `false` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_deadlocks_enabled"></a> [deadlocks\_enabled](#input\_deadlocks\_enabled) | Enable SQL Database deadlock monitor | `bool` | `true` | no |
| <a name="input_deadlocks_evaluation_window"></a> [deadlocks\_evaluation\_window](#input\_deadlocks\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_deadlocks_no_data_window"></a> [deadlocks\_no\_data\_window](#input\_deadlocks\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_deadlocks_threshold_critical"></a> [deadlocks\_threshold\_critical](#input\_deadlocks\_threshold\_critical) | Number of deadlocks in the evaluation window at which to alert critical | `number` | `5` | no |
| <a name="input_deadlocks_threshold_warning"></a> [deadlocks\_threshold\_warning](#input\_deadlocks\_threshold\_warning) | Number of deadlocks in the evaluation window at which to alert warning | `number` | `1` | no |
| <a name="input_deadlocks_use_message"></a> [deadlocks\_use\_message](#input\_deadlocks\_use\_message) | Whether to use the query alert base message for SQL Database deadlock monitor | `bool` | `false` | no |
| <a name="input_dtu_consumption_high_enabled"></a> [dtu\_consumption\_high\_enabled](#input\_dtu\_consumption\_high\_enabled) | Enable SQL Database DTU consumption monitor. Disabled by default: `dtu_consumption_percent` is emitted only under the DTU purchasing model, so a vCore database reports nothing and the monitor would sit in no-data. Use `cpu_high_enabled`, which is valid under both models, and enable this only for DTU-model databases | `bool` | `false` | no |
| <a name="input_dtu_consumption_high_evaluation_window"></a> [dtu\_consumption\_high\_evaluation\_window](#input\_dtu\_consumption\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_dtu_consumption_high_no_data_window"></a> [dtu\_consumption\_high\_no\_data\_window](#input\_dtu\_consumption\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_dtu_consumption_high_threshold_critical"></a> [dtu\_consumption\_high\_threshold\_critical](#input\_dtu\_consumption\_high\_threshold\_critical) | DTU consumption percentage at which to alert critical | `number` | `90` | no |
| <a name="input_dtu_consumption_high_threshold_warning"></a> [dtu\_consumption\_high\_threshold\_warning](#input\_dtu\_consumption\_high\_threshold\_warning) | DTU consumption percentage at which to alert warning | `number` | `80` | no |
| <a name="input_dtu_consumption_high_use_message"></a> [dtu\_consumption\_high\_use\_message](#input\_dtu\_consumption\_high\_use\_message) | Whether to use the query alert base message for SQL Database DTU consumption monitor | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br>  "name",<br>  "aws_account",<br>  "env",<br>  "datadog_managed"<br>]</pre> | no |
| <a name="input_log_write_high_enabled"></a> [log\_write\_high\_enabled](#input\_log\_write\_high\_enabled) | Enable SQL Database log write utilization monitor. Disabled by default: write-heavy batch and ETL workloads saturate the log writer during normal operation, so this needs a per-database threshold before it is useful | `bool` | `false` | no |
| <a name="input_log_write_high_evaluation_window"></a> [log\_write\_high\_evaluation\_window](#input\_log\_write\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_log_write_high_no_data_window"></a> [log\_write\_high\_no\_data\_window](#input\_log\_write\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_log_write_high_threshold_critical"></a> [log\_write\_high\_threshold\_critical](#input\_log\_write\_high\_threshold\_critical) | Log write utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_log_write_high_threshold_warning"></a> [log\_write\_high\_threshold\_warning](#input\_log\_write\_high\_threshold\_warning) | Log write utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_log_write_high_use_message"></a> [log\_write\_high\_use\_message](#input\_log\_write\_high\_use\_message) | Whether to use the query alert base message for SQL Database log write utilization monitor | `bool` | `false` | no |
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
| <a name="input_sessions_high_enabled"></a> [sessions\_high\_enabled](#input\_sessions\_high\_enabled) | Enable SQL Database session utilization monitor | `bool` | `true` | no |
| <a name="input_sessions_high_evaluation_window"></a> [sessions\_high\_evaluation\_window](#input\_sessions\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_sessions_high_no_data_window"></a> [sessions\_high\_no\_data\_window](#input\_sessions\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_sessions_high_threshold_critical"></a> [sessions\_high\_threshold\_critical](#input\_sessions\_high\_threshold\_critical) | Session utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_sessions_high_threshold_warning"></a> [sessions\_high\_threshold\_warning](#input\_sessions\_high\_threshold\_warning) | Session utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_sessions_high_use_message"></a> [sessions\_high\_use\_message](#input\_sessions\_high\_use\_message) | Whether to use the query alert base message for SQL Database session utilization monitor | `bool` | `false` | no |
| <a name="input_storage_high_enabled"></a> [storage\_high\_enabled](#input\_storage\_high\_enabled) | Enable SQL Database storage utilization monitor | `bool` | `true` | no |
| <a name="input_storage_high_evaluation_window"></a> [storage\_high\_evaluation\_window](#input\_storage\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_storage_high_no_data_window"></a> [storage\_high\_no\_data\_window](#input\_storage\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_storage_high_threshold_critical"></a> [storage\_high\_threshold\_critical](#input\_storage\_high\_threshold\_critical) | Database storage utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_storage_high_threshold_warning"></a> [storage\_high\_threshold\_warning](#input\_storage\_high\_threshold\_warning) | Database storage utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_storage_high_use_message"></a> [storage\_high\_use\_message](#input\_storage\_high\_use\_message) | Whether to use the query alert base message for SQL Database storage utilization monitor | `bool` | `false` | no |
| <a name="input_team"></a> [team](#input\_team) | Team supporting the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_timeout_h"></a> [timeout\_h](#input\_timeout\_h) | Auto-resolve alert in specified hours if condition no longer matches | `number` | `0` | no |
| <a name="input_title_prefix"></a> [title\_prefix](#input\_title\_prefix) | Prefix all alerts with specified value in brackets | `string` | `null` | no |
| <a name="input_title_suffix"></a> [title\_suffix](#input\_title\_suffix) | Suffix all alerts with specified value in parenthesis | `string` | `null` | no |
| <a name="input_warn_priority"></a> [warn\_priority](#input\_warn\_priority) | Priority for alerts with no data (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_workers_high_enabled"></a> [workers\_high\_enabled](#input\_workers\_high\_enabled) | Enable SQL Database worker utilization monitor | `bool` | `true` | no |
| <a name="input_workers_high_evaluation_window"></a> [workers\_high\_evaluation\_window](#input\_workers\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_workers_high_no_data_window"></a> [workers\_high\_no\_data\_window](#input\_workers\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_workers_high_threshold_critical"></a> [workers\_high\_threshold\_critical](#input\_workers\_high\_threshold\_critical) | Worker utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_workers_high_threshold_warning"></a> [workers\_high\_threshold\_warning](#input\_workers\_high\_threshold\_warning) | Worker utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_workers_high_use_message"></a> [workers\_high\_use\_message](#input\_workers\_high\_use\_message) | Whether to use the query alert base message for SQL Database worker utilization monitor | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
