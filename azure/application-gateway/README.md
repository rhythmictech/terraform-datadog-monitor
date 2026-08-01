# terraform-datadog-monitor/azure/application-gateway

Configures monitors for Azure Application Gateway (`azure.network_applicationgateways.*`).

Backend health (`unhealthy_hosts`, `healthy_hosts_low`) and `failed_requests` are enabled by default.
Everything else is gated on a SKU or on an unconfirmed metric dimension, and ships disabled.

## SKU-dependent monitors

Azure splits this namespace across gateway generations, so enabling the wrong ones produces permanent
no-data:

| Monitor | Availability |
|---|---|
| `cpu_utilization_high` | **V1 SKU only** (retired for new deployments) |
| `backend_latency`, `capacity_units_high`, `backend_5xx_rate` | **V2 SKU only** |

## The backend 5xx monitor and its status-group tag

`backend_response_status` reports every status class under one metric name, discriminated by a
dimension, rather than as one metric per class. The `backend_5xx_rate` monitor therefore has to filter
on that dimension's Datadog tag key.

Azure names the dimension `HttpStatusGroup`. The expected Datadog key is the lowercased
`httpstatusgroup`, which is the default of `backend_5xx_rate_status_tag`, but this has **not** been
confirmed against live data. Confirm it before enabling the monitor, otherwise the query returns
nothing and, because `notify_no_data` defaults to false, does so silently. The key is a variable
specifically so it can be corrected without a module change.

`failed_requests` is the enabled-by-default error signal precisely because it needs no dimension
filter. Note it counts gateway-level failures, which is a different signal from backend 5xx responses,
so the two are complementary rather than redundant.

## Running the tests

Unit tests live in `tests/` and assert monitor toggles, metric namespaces, group-by tags, threshold
plumbing, and tag composition against a mocked Datadog provider (no API access needed). They also cover
the status-tag filter composition, including that it preserves a user-supplied exclude filter.

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
| [datadog_monitor.backend_5xx_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.backend_latency](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.capacity_units_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.cpu_utilization_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.failed_requests](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.healthy_hosts_low](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.unhealthy_hosts](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_backend_5xx_rate_enabled"></a> [backend\_5xx\_rate\_enabled](#input\_backend\_5xx\_rate\_enabled) | Enable Application Gateway backend 5xx rate monitor. Disabled by default: `backend_response_status` reports all status classes under one metric name discriminated by a dimension, so this query depends on the Datadog tag key for that dimension (see `backend_5xx_rate_status_tag`). Confirm that key against live data before enabling, otherwise the query silently returns nothing. Also note the metric is V2 SKU only | `bool` | `false` | no |
| <a name="input_backend_5xx_rate_evaluation_window"></a> [backend\_5xx\_rate\_evaluation\_window](#input\_backend\_5xx\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_backend_5xx_rate_no_data_window"></a> [backend\_5xx\_rate\_no\_data\_window](#input\_backend\_5xx\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_backend_5xx_rate_status_tag"></a> [backend\_5xx\_rate\_status\_tag](#input\_backend\_5xx\_rate\_status\_tag) | Datadog tag key carrying the Application Gateway backend response status group. Azure names the dimension `HttpStatusGroup`; the lowercased form here is the expected Datadog key but has NOT been confirmed against live data. Exposed as a variable so it can be corrected without a module change | `string` | `"httpstatusgroup"` | no |
| <a name="input_backend_5xx_rate_threshold_critical"></a> [backend\_5xx\_rate\_threshold\_critical](#input\_backend\_5xx\_rate\_threshold\_critical) | Backend 5xx percentage of total requests at which to alert critical | `number` | `5` | no |
| <a name="input_backend_5xx_rate_threshold_warning"></a> [backend\_5xx\_rate\_threshold\_warning](#input\_backend\_5xx\_rate\_threshold\_warning) | Backend 5xx percentage of total requests at which to alert warning | `number` | `1` | no |
| <a name="input_backend_5xx_rate_use_message"></a> [backend\_5xx\_rate\_use\_message](#input\_backend\_5xx\_rate\_use\_message) | Whether to use the query alert base message for Application Gateway backend 5xx rate monitor | `bool` | `false` | no |
| <a name="input_backend_latency_enabled"></a> [backend\_latency\_enabled](#input\_backend\_latency\_enabled) | Enable Application Gateway backend latency monitor. Disabled by default: `backend_connect_time` is available only on the V2 SKU, so a V1 gateway reports nothing and the monitor would sit in no-data | `bool` | `false` | no |
| <a name="input_backend_latency_evaluation_window"></a> [backend\_latency\_evaluation\_window](#input\_backend\_latency\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_backend_latency_no_data_window"></a> [backend\_latency\_no\_data\_window](#input\_backend\_latency\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_backend_latency_threshold_critical"></a> [backend\_latency\_threshold\_critical](#input\_backend\_latency\_threshold\_critical) | Backend connect time in milliseconds at which to alert critical | `number` | `1000` | no |
| <a name="input_backend_latency_threshold_warning"></a> [backend\_latency\_threshold\_warning](#input\_backend\_latency\_threshold\_warning) | Backend connect time in milliseconds at which to alert warning | `number` | `500` | no |
| <a name="input_backend_latency_use_message"></a> [backend\_latency\_use\_message](#input\_backend\_latency\_use\_message) | Whether to use the query alert base message for Application Gateway backend latency monitor | `bool` | `false` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:application-gateway"<br>]</pre> | no |
| <a name="input_capacity_units_high_enabled"></a> [capacity\_units\_high\_enabled](#input\_capacity\_units\_high\_enabled) | Enable Application Gateway capacity unit monitor. Disabled by default: `capacity_units` is available only on the V2 SKU, and the meaningful ceiling depends on the gateway's configured maximum instance count, so the threshold must be set per gateway | `bool` | `false` | no |
| <a name="input_capacity_units_high_evaluation_window"></a> [capacity\_units\_high\_evaluation\_window](#input\_capacity\_units\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_capacity_units_high_no_data_window"></a> [capacity\_units\_high\_no\_data\_window](#input\_capacity\_units\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_capacity_units_high_threshold_critical"></a> [capacity\_units\_high\_threshold\_critical](#input\_capacity\_units\_high\_threshold\_critical) | Consumed capacity units at which to alert critical. Set relative to the gateway's configured maximum instance count | `number` | `90` | no |
| <a name="input_capacity_units_high_threshold_warning"></a> [capacity\_units\_high\_threshold\_warning](#input\_capacity\_units\_high\_threshold\_warning) | Consumed capacity units at which to alert warning | `number` | `80` | no |
| <a name="input_capacity_units_high_use_message"></a> [capacity\_units\_high\_use\_message](#input\_capacity\_units\_high\_use\_message) | Whether to use the query alert base message for Application Gateway capacity unit monitor | `bool` | `false` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_cpu_utilization_high_enabled"></a> [cpu\_utilization\_high\_enabled](#input\_cpu\_utilization\_high\_enabled) | Enable Application Gateway CPU utilization monitor. Disabled by default: `cpu_utilization` is available only on the V1 SKU, which Azure has retired for new deployments. V2 gateways should use `capacity_units_high_enabled` instead | `bool` | `false` | no |
| <a name="input_cpu_utilization_high_evaluation_window"></a> [cpu\_utilization\_high\_evaluation\_window](#input\_cpu\_utilization\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cpu_utilization_high_no_data_window"></a> [cpu\_utilization\_high\_no\_data\_window](#input\_cpu\_utilization\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_utilization_high_threshold_critical"></a> [cpu\_utilization\_high\_threshold\_critical](#input\_cpu\_utilization\_high\_threshold\_critical) | Gateway CPU utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_cpu_utilization_high_threshold_warning"></a> [cpu\_utilization\_high\_threshold\_warning](#input\_cpu\_utilization\_high\_threshold\_warning) | Gateway CPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_cpu_utilization_high_use_message"></a> [cpu\_utilization\_high\_use\_message](#input\_cpu\_utilization\_high\_use\_message) | Whether to use the query alert base message for Application Gateway CPU utilization monitor | `bool` | `false` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_failed_requests_enabled"></a> [failed\_requests\_enabled](#input\_failed\_requests\_enabled) | Enable Application Gateway failed request monitor. This is the enabled-by-default error signal because it needs no status-group dimension filter, unlike `backend_5xx_rate` | `bool` | `true` | no |
| <a name="input_failed_requests_evaluation_window"></a> [failed\_requests\_evaluation\_window](#input\_failed\_requests\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_failed_requests_no_data_window"></a> [failed\_requests\_no\_data\_window](#input\_failed\_requests\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_failed_requests_threshold_critical"></a> [failed\_requests\_threshold\_critical](#input\_failed\_requests\_threshold\_critical) | Number of failed requests in the evaluation window at which to alert critical | `number` | `10` | no |
| <a name="input_failed_requests_threshold_warning"></a> [failed\_requests\_threshold\_warning](#input\_failed\_requests\_threshold\_warning) | Number of failed requests in the evaluation window at which to alert warning | `number` | `1` | no |
| <a name="input_failed_requests_use_message"></a> [failed\_requests\_use\_message](#input\_failed\_requests\_use\_message) | Whether to use the query alert base message for Application Gateway failed request monitor | `bool` | `false` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br>  "name",<br>  "aws_account",<br>  "env",<br>  "datadog_managed"<br>]</pre> | no |
| <a name="input_healthy_hosts_low_enabled"></a> [healthy\_hosts\_low\_enabled](#input\_healthy\_hosts\_low\_enabled) | Enable Application Gateway healthy backend host monitor | `bool` | `true` | no |
| <a name="input_healthy_hosts_low_evaluation_window"></a> [healthy\_hosts\_low\_evaluation\_window](#input\_healthy\_hosts\_low\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_healthy_hosts_low_no_data_window"></a> [healthy\_hosts\_low\_no\_data\_window](#input\_healthy\_hosts\_low\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_healthy_hosts_low_threshold_critical"></a> [healthy\_hosts\_low\_threshold\_critical](#input\_healthy\_hosts\_low\_threshold\_critical) | Alert critical when the healthy backend host count falls below this value | `number` | `1` | no |
| <a name="input_healthy_hosts_low_threshold_warning"></a> [healthy\_hosts\_low\_threshold\_warning](#input\_healthy\_hosts\_low\_threshold\_warning) | Alert warning when the healthy backend host count falls below this value. Above the critical threshold because this monitor alerts on a value being too low | `number` | `2` | no |
| <a name="input_healthy_hosts_low_use_message"></a> [healthy\_hosts\_low\_use\_message](#input\_healthy\_hosts\_low\_use\_message) | Whether to use the query alert base message for Application Gateway healthy backend host monitor | `bool` | `false` | no |
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
| <a name="input_unhealthy_hosts_enabled"></a> [unhealthy\_hosts\_enabled](#input\_unhealthy\_hosts\_enabled) | Enable Application Gateway unhealthy backend host monitor | `bool` | `true` | no |
| <a name="input_unhealthy_hosts_evaluation_window"></a> [unhealthy\_hosts\_evaluation\_window](#input\_unhealthy\_hosts\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_unhealthy_hosts_no_data_window"></a> [unhealthy\_hosts\_no\_data\_window](#input\_unhealthy\_hosts\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_unhealthy_hosts_threshold_critical"></a> [unhealthy\_hosts\_threshold\_critical](#input\_unhealthy\_hosts\_threshold\_critical) | Number of unhealthy backend hosts at which to alert critical. Defaults to 0 so that any unhealthy backend alerts, since the query compares with `>` | `number` | `0` | no |
| <a name="input_unhealthy_hosts_use_message"></a> [unhealthy\_hosts\_use\_message](#input\_unhealthy\_hosts\_use\_message) | Whether to use the query alert base message for Application Gateway unhealthy backend host monitor | `bool` | `false` | no |
| <a name="input_warn_priority"></a> [warn\_priority](#input\_warn\_priority) | Priority for alerts with no data (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
