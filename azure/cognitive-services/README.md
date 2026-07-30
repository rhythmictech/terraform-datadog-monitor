# terraform-datadog-monitor/azure/cognitive-services

Configures monitors for Azure AI / Cognitive Services accounts
(`azure.cognitiveservices_accounts.*`).

One module covers **both** Azure AI Foundry (Azure OpenAI) and Document Intelligence (Form Recognizer):
they report into the same Datadog metric namespace and are distinguished by the `kind` tag, which this
module includes in every monitor's group-by so alerts stay attributable per account type.

Monitors enabled by default (`error_rate`, `availability_rate`, `blocked_calls`) are independent of how
the account is provisioned. The remaining monitors are disabled by default because they depend on the
deployment model:

| Monitor | Why disabled |
|---|---|
| `latency` | Datadog does not document the metric unit; thresholds assume milliseconds |
| `provisioned_utilization` | Emitted only by provisioned-throughput (PTU) deployments |
| `model_availability_rate` | Azure OpenAI deployments only |

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
| [datadog_monitor.availability_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.blocked_calls](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.error_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.latency](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.model_availability_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.provisioned_utilization](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_availability_rate_enabled"></a> [availability\_rate\_enabled](#input\_availability\_rate\_enabled) | Enable Cognitive Services availability rate monitor | `bool` | `true` | no |
| <a name="input_availability_rate_evaluation_window"></a> [availability\_rate\_evaluation\_window](#input\_availability\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_availability_rate_no_data_window"></a> [availability\_rate\_no\_data\_window](#input\_availability\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_availability_rate_threshold_critical"></a> [availability\_rate\_threshold\_critical](#input\_availability\_rate\_threshold\_critical) | Availability rate percentage below which to alert critical | `number` | `95` | no |
| <a name="input_availability_rate_threshold_warning"></a> [availability\_rate\_threshold\_warning](#input\_availability\_rate\_threshold\_warning) | Availability rate percentage below which to alert warning | `number` | `99` | no |
| <a name="input_availability_rate_use_message"></a> [availability\_rate\_use\_message](#input\_availability\_rate\_use\_message) | Whether to use the query alert base message for Cognitive Services availability rate monitor | `bool` | `false` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:cognitive-services"<br>]</pre> | no |
| <a name="input_blocked_calls_enabled"></a> [blocked\_calls\_enabled](#input\_blocked\_calls\_enabled) | Enable Cognitive Services blocked call monitor (quota and rate-limit rejections) | `bool` | `true` | no |
| <a name="input_blocked_calls_evaluation_window"></a> [blocked\_calls\_evaluation\_window](#input\_blocked\_calls\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_blocked_calls_no_data_window"></a> [blocked\_calls\_no\_data\_window](#input\_blocked\_calls\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_blocked_calls_threshold_critical"></a> [blocked\_calls\_threshold\_critical](#input\_blocked\_calls\_threshold\_critical) | Blocked call count above which to alert critical (the default of 0 alerts on any blocked call in the evaluation window) | `number` | `0` | no |
| <a name="input_blocked_calls_use_message"></a> [blocked\_calls\_use\_message](#input\_blocked\_calls\_use\_message) | Whether to use the query alert base message for Cognitive Services blocked call monitor | `bool` | `false` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_error_rate_enabled"></a> [error\_rate\_enabled](#input\_error\_rate\_enabled) | Enable Cognitive Services error rate monitor | `bool` | `true` | no |
| <a name="input_error_rate_evaluation_window"></a> [error\_rate\_evaluation\_window](#input\_error\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_error_rate_no_data_window"></a> [error\_rate\_no\_data\_window](#input\_error\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_error_rate_threshold_critical"></a> [error\_rate\_threshold\_critical](#input\_error\_rate\_threshold\_critical) | Percentage of calls returning errors at which to alert critical | `number` | `5` | no |
| <a name="input_error_rate_threshold_warning"></a> [error\_rate\_threshold\_warning](#input\_error\_rate\_threshold\_warning) | Percentage of calls returning errors at which to alert warning | `number` | `1` | no |
| <a name="input_error_rate_use_message"></a> [error\_rate\_use\_message](#input\_error\_rate\_use\_message) | Whether to use the query alert base message for Cognitive Services error rate monitor | `bool` | `false` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br>  "name",<br>  "aws_account",<br>  "env",<br>  "datadog_managed"<br>]</pre> | no |
| <a name="input_latency_enabled"></a> [latency\_enabled](#input\_latency\_enabled) | Enable Cognitive Services latency monitor (disabled by default; Datadog does not document the metric unit, so confirm against live data before enabling) | `bool` | `false` | no |
| <a name="input_latency_evaluation_window"></a> [latency\_evaluation\_window](#input\_latency\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_latency_no_data_window"></a> [latency\_no\_data\_window](#input\_latency\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_latency_threshold_critical"></a> [latency\_threshold\_critical](#input\_latency\_threshold\_critical) | Latency at which to alert critical (assumed milliseconds; confirm the metric unit before relying on this) | `number` | `5000` | no |
| <a name="input_latency_threshold_warning"></a> [latency\_threshold\_warning](#input\_latency\_threshold\_warning) | Latency at which to alert warning (assumed milliseconds; confirm the metric unit before relying on this) | `number` | `2000` | no |
| <a name="input_latency_use_message"></a> [latency\_use\_message](#input\_latency\_use\_message) | Whether to use the query alert base message for Cognitive Services latency monitor | `bool` | `false` | no |
| <a name="input_model_availability_rate_enabled"></a> [model\_availability\_rate\_enabled](#input\_model\_availability\_rate\_enabled) | Enable Cognitive Services model availability monitor (disabled by default; Azure OpenAI deployments only) | `bool` | `false` | no |
| <a name="input_model_availability_rate_evaluation_window"></a> [model\_availability\_rate\_evaluation\_window](#input\_model\_availability\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_model_availability_rate_no_data_window"></a> [model\_availability\_rate\_no\_data\_window](#input\_model\_availability\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_model_availability_rate_threshold_critical"></a> [model\_availability\_rate\_threshold\_critical](#input\_model\_availability\_rate\_threshold\_critical) | Model availability rate percentage below which to alert critical | `number` | `95` | no |
| <a name="input_model_availability_rate_threshold_warning"></a> [model\_availability\_rate\_threshold\_warning](#input\_model\_availability\_rate\_threshold\_warning) | Model availability rate percentage below which to alert warning | `number` | `99` | no |
| <a name="input_model_availability_rate_use_message"></a> [model\_availability\_rate\_use\_message](#input\_model\_availability\_rate\_use\_message) | Whether to use the query alert base message for Cognitive Services model availability monitor | `bool` | `false` | no |
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
| <a name="input_provisioned_utilization_enabled"></a> [provisioned\_utilization\_enabled](#input\_provisioned\_utilization\_enabled) | Enable Cognitive Services provisioned utilization monitor (disabled by default; emitted only by provisioned-throughput (PTU) deployments) | `bool` | `false` | no |
| <a name="input_provisioned_utilization_evaluation_window"></a> [provisioned\_utilization\_evaluation\_window](#input\_provisioned\_utilization\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_provisioned_utilization_no_data_window"></a> [provisioned\_utilization\_no\_data\_window](#input\_provisioned\_utilization\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_provisioned_utilization_threshold_critical"></a> [provisioned\_utilization\_threshold\_critical](#input\_provisioned\_utilization\_threshold\_critical) | Provisioned throughput utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_provisioned_utilization_threshold_warning"></a> [provisioned\_utilization\_threshold\_warning](#input\_provisioned\_utilization\_threshold\_warning) | Provisioned throughput utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_provisioned_utilization_use_message"></a> [provisioned\_utilization\_use\_message](#input\_provisioned\_utilization\_use\_message) | Whether to use the query alert base message for Cognitive Services provisioned utilization monitor | `bool` | `false` | no |
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
