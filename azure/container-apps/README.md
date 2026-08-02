# terraform-datadog-monitor/azure/container-apps

Configures monitors for Azure Container Apps (`azure.app_containerapps.*`), covering replica restarts,
replica availability, CPU and memory saturation, response time and the server-error rate.

Pair with `azure/aks` if you run both Azure container runtimes. The two are complementary rather than
alternatives: this module carries the **restart and replica-availability** signals that AKS platform metrics
do not publish at all.

## Metric name evidence

Datadog publishes names for three of these metrics directly. The rest are derived from Microsoft's
`Microsoft.App/containerApps` REST API metric names using the PascalCase-to-snake_case convention that those
three confirm.

| Metric | Evidence |
|---|---|
| `restart_count` | Datadog-published |
| `replicas` | Datadog-published |
| `requests` | Datadog-published |
| `cold_start` | Datadog-published (in the enhanced namespace, see below) |
| `cpu_percentage`, `memory_percentage`, `response_time`, `resiliency_request_timeouts`, `resiliency_ejected_hosts`, `gpu_utilization_percentage` | Azure REST API name confirmed; Datadog name inferred by convention |

Confirm the inferred names in the Datadog metric explorer on a first deployment. A wrong metric name
produces a monitor that never fires, and because `notify_no_data` defaults to `false` that failure is
silent.

## Two traps in this namespace

### `restart_count` is cumulative

Azure documents `RestartCount` as "the cumulative number of times the replica has restarted since it was
created". Alerting on the raw value would **latch**: once a replica crossed the threshold the monitor would
stay triggered for that replica's entire life, and a replica that restarted six times over three months
would score identically to one crash-looping right now.

`restart_count_high` therefore wraps the metric in `monotonic_diff()`, which graphs the per-interval delta
and counts only positive changes, so a replica replacement resetting the counter to zero does not register
as a negative spike. A test guards the wrapper, because removing it is an easy and invisible regression.

### `response_time` is in MILLISECONDS

Unlike `azure/app-service` and `azure/functions`, where `average_response_time` is in seconds and the
default critical threshold is `5`, this metric is milliseconds. The defaults here are `2000` / `1000`
accordingly. Copying a threshold across from those modules would mean alerting at five milliseconds. A test
asserts the threshold stays at or above 1000 for exactly this reason.

## The 5xx monitor depends on an unconfirmed Datadog tag

`http_5xx_rate` ships **enabled** while resting on a tag key and value pair that has **not** been confirmed
against live data, and it is the highest-risk assumption in this module.

`requests` reports every status class under one metric name, discriminated by a dimension. Azure names that
dimension **`statusCodeCategory`**, in camelCase. Datadog's Azure integration maps dimensions to tags
("Metrics are collected with all available dimensions (which are mapped to tags in Datadog)"), but the
resulting key spelling is not documented, so the lowercase `statuscodecategory` used here is an assumption.

**If the key or value is wrong the query returns no data, silently.** On a first deployment:

1. Query `azure.app_containerapps.requests` in the Datadog metric explorer and read the real tag key and
   values off the live series.
2. Set `http_5xx_rate_status_tag_key` and `http_5xx_rate_status_tag_value` to match. They exist so a wrong
   guess is a tfvars fix rather than a module release.
3. Consider `notify_no_data = true` for the first few days so a wrong pair announces itself.

Only the numerator carries the status filter; the denominator stays unfiltered so the ratio is
5xx-over-total. A test asserts the filter appears exactly once, because scoping the denominator to 5xx as
well would make the rate permanently 100 percent.

## Scale-to-zero apps must disable `replicas_low`

`replicas_low` alerts when the running replica count drops below 1. An app with a scale-to-zero rule idles
at zero replicas by design and will alert continuously. Set `replicas_low_enabled = false` for those apps
rather than lowering the threshold, since a threshold below 1 cannot fire.

## Monitors disabled by default

| Monitor | Why |
|---|---|
| `cold_start_high` | The only metric here that requires the **Datadog Serverless Agent** deployed inside the container app, either as a sidecar or wrapping the application container. Without it the metric is never emitted. Note the namespace is `azure.containerapps.enhanced.cold_start`, with **no `app_` infix**, unlike every other metric in this module. A test guards that spelling. |
| `resiliency_request_timeouts` | The resiliency metric family is only emitted when a resiliency policy is configured on the app. |
| `resiliency_ejected_hosts` | Same resiliency-policy gate. Threshold defaults to 0, so any ejected host alerts once enabled. |
| `gpu_utilization_high` | GPU workloads only. Azure labels the metric Preview. |

## Metrics deliberately not modelled

`UsageNanoCores`, `WorkingSetBytes`, `RxBytes` and `TxBytes` are absolute counterparts of the percentage
metrics, and an absolute threshold is meaningless without knowing the container's configured limits.
`CoresQuotaUsed` and `TotalCoresQuotaUsed` are quota gauges rather than conditions.
`ResiliencyConnectTimeouts`, `ResiliencyRequestRetries`, `ResiliencyEjectionsAborted` and
`ResiliencyRequestsPendingConnectionPool` are informational members of the resiliency family already
represented by the two monitors above.

The entire **Java** category, twelve `Jvm*` metrics, is omitted on purpose. JVM internals belong to APM and
the Agent's JMX integration, and wiring them in here would make this the only language-specific module in
the repo.

## A note on Azure's Preview labelling

`CpuPercentage`, `MemoryPercentage`, `ResponseTime` and `GpuUtilizationPercentage` all carry "(Preview)" in
their Azure display names. This module does not disable a monitor merely for being labelled preview, only
for a real feature gate. The labelling is recorded so nobody is surprised if Microsoft changes it.

## Group by

```
by {name,subscription_name,resource_group,region,env,datadog_managed}
```

`revisionName` would be a useful split, since Container Apps traffic-splits across revisions, but it is an
unconfirmed tag and grouping by a tag that does not exist fragments every series into an `N/A` group.
Confirm it against live data first; adding it is then a one-line change.

## Running the tests

Unit tests live in `tests/` and assert monitor toggles, metric namespaces, group-by tags, threshold
plumbing and tag composition against a mocked Datadog provider (no API access needed). Module-specific
guards check the `monotonic_diff()` wrapper, the enhanced namespace spelling, that the status filter is
spliced rather than concatenated and appears only in the numerator, that the tag key and value are
overridable, that the below-threshold monitor keeps its warning above its critical, and that the response
time threshold stays in milliseconds.

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
| [datadog_monitor.cold_start_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.cpu_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.gpu_utilization_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.http_5xx_rate](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.memory_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.replicas_low](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.resiliency_ejected_hosts](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.resiliency_request_timeouts](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.response_time_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.restart_count_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:container-apps"<br>]</pre> | no |
| <a name="input_cold_start_high_enabled"></a> [cold\_start\_high\_enabled](#input\_cold\_start\_high\_enabled) | Enable Container App cold start monitor. Disabled by default: this is the only metric in this module that requires the Datadog Serverless Agent deployed inside the container app (sidecar or in-container). It also lives in the `azure.containerapps.enhanced.*` namespace, with no `app_` infix, unlike every other metric here | `bool` | `false` | no |
| <a name="input_cold_start_high_evaluation_window"></a> [cold\_start\_high\_evaluation\_window](#input\_cold\_start\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cold_start_high_no_data_window"></a> [cold\_start\_high\_no\_data\_window](#input\_cold\_start\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cold_start_high_threshold_critical"></a> [cold\_start\_high\_threshold\_critical](#input\_cold\_start\_high\_threshold\_critical) | Cold starts within the evaluation window at which to alert critical | `number` | `10` | no |
| <a name="input_cold_start_high_threshold_warning"></a> [cold\_start\_high\_threshold\_warning](#input\_cold\_start\_high\_threshold\_warning) | Cold starts within the evaluation window at which to alert warning | `number` | `1` | no |
| <a name="input_cold_start_high_use_message"></a> [cold\_start\_high\_use\_message](#input\_cold\_start\_high\_use\_message) | Whether to use the query alert base message for Container App cold start monitor | `bool` | `false` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_cpu_high_enabled"></a> [cpu\_high\_enabled](#input\_cpu\_high\_enabled) | Enable Container App CPU utilization monitor. Azure labels this metric Preview | `bool` | `true` | no |
| <a name="input_cpu_high_evaluation_window"></a> [cpu\_high\_evaluation\_window](#input\_cpu\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_cpu_high_no_data_window"></a> [cpu\_high\_no\_data\_window](#input\_cpu\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_cpu_high_threshold_critical"></a> [cpu\_high\_threshold\_critical](#input\_cpu\_high\_threshold\_critical) | CPU utilization percentage (against the container's CPU limit) at which to alert critical | `number` | `90` | no |
| <a name="input_cpu_high_threshold_warning"></a> [cpu\_high\_threshold\_warning](#input\_cpu\_high\_threshold\_warning) | CPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_cpu_high_use_message"></a> [cpu\_high\_use\_message](#input\_cpu\_high\_use\_message) | Whether to use the query alert base message for Container App CPU utilization monitor | `bool` | `false` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_gpu_utilization_high_enabled"></a> [gpu\_utilization\_high\_enabled](#input\_gpu\_utilization\_high\_enabled) | Enable Container App GPU utilization monitor. Disabled by default: GPU workloads only. Azure labels this metric Preview | `bool` | `false` | no |
| <a name="input_gpu_utilization_high_evaluation_window"></a> [gpu\_utilization\_high\_evaluation\_window](#input\_gpu\_utilization\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_gpu_utilization_high_no_data_window"></a> [gpu\_utilization\_high\_no\_data\_window](#input\_gpu\_utilization\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_gpu_utilization_high_threshold_critical"></a> [gpu\_utilization\_high\_threshold\_critical](#input\_gpu\_utilization\_high\_threshold\_critical) | GPU utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_gpu_utilization_high_threshold_warning"></a> [gpu\_utilization\_high\_threshold\_warning](#input\_gpu\_utilization\_high\_threshold\_warning) | GPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_gpu_utilization_high_use_message"></a> [gpu\_utilization\_high\_use\_message](#input\_gpu\_utilization\_high\_use\_message) | Whether to use the query alert base message for Container App GPU utilization monitor | `bool` | `false` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br>  "name",<br>  "aws_account",<br>  "env",<br>  "datadog_managed"<br>]</pre> | no |
| <a name="input_http_5xx_rate_enabled"></a> [http\_5xx\_rate\_enabled](#input\_http\_5xx\_rate\_enabled) | Enable Container App 5xx rate monitor. NOTE: `requests` reports all status classes under one metric name discriminated by a dimension, so this query depends on the Datadog tag key AND value for that dimension. Azure names the dimension `statusCodeCategory`, in camelCase, so the assumed lowercase key carries the highest tag-spelling risk in this module. If either is wrong the query silently returns nothing | `bool` | `true` | no |
| <a name="input_http_5xx_rate_evaluation_window"></a> [http\_5xx\_rate\_evaluation\_window](#input\_http\_5xx\_rate\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_http_5xx_rate_no_data_window"></a> [http\_5xx\_rate\_no\_data\_window](#input\_http\_5xx\_rate\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_http_5xx_rate_status_tag_key"></a> [http\_5xx\_rate\_status\_tag\_key](#input\_http\_5xx\_rate\_status\_tag\_key) | Datadog tag key carrying the HTTP status class. Azure names the dimension `statusCodeCategory`; the lowercased form here is the expected Datadog key but has NOT been confirmed against live data. Exposed as a variable so it can be corrected without a module change | `string` | `"statuscodecategory"` | no |
| <a name="input_http_5xx_rate_status_tag_value"></a> [http\_5xx\_rate\_status\_tag\_value](#input\_http\_5xx\_rate\_status\_tag\_value) | Datadog tag value identifying the server-error status class. NOT confirmed against live data | `string` | `"5xx"` | no |
| <a name="input_http_5xx_rate_threshold_critical"></a> [http\_5xx\_rate\_threshold\_critical](#input\_http\_5xx\_rate\_threshold\_critical) | Percentage of requests returning 5xx at which to alert critical | `number` | `5` | no |
| <a name="input_http_5xx_rate_threshold_warning"></a> [http\_5xx\_rate\_threshold\_warning](#input\_http\_5xx\_rate\_threshold\_warning) | Percentage of requests returning 5xx at which to alert warning | `number` | `1` | no |
| <a name="input_http_5xx_rate_use_message"></a> [http\_5xx\_rate\_use\_message](#input\_http\_5xx\_rate\_use\_message) | Whether to use the query alert base message for Container App 5xx rate monitor | `bool` | `false` | no |
| <a name="input_memory_high_enabled"></a> [memory\_high\_enabled](#input\_memory\_high\_enabled) | Enable Container App memory utilization monitor. Azure labels this metric Preview | `bool` | `true` | no |
| <a name="input_memory_high_evaluation_window"></a> [memory\_high\_evaluation\_window](#input\_memory\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_memory_high_no_data_window"></a> [memory\_high\_no\_data\_window](#input\_memory\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_memory_high_threshold_critical"></a> [memory\_high\_threshold\_critical](#input\_memory\_high\_threshold\_critical) | Memory utilization percentage (against the container's memory limit) at which to alert critical | `number` | `90` | no |
| <a name="input_memory_high_threshold_warning"></a> [memory\_high\_threshold\_warning](#input\_memory\_high\_threshold\_warning) | Memory utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_memory_high_use_message"></a> [memory\_high\_use\_message](#input\_memory\_high\_use\_message) | Whether to use the query alert base message for Container App memory utilization monitor | `bool` | `false` | no |
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
| <a name="input_replicas_low_enabled"></a> [replicas\_low\_enabled](#input\_replicas\_low\_enabled) | Enable Container App running replica monitor | `bool` | `true` | no |
| <a name="input_replicas_low_evaluation_window"></a> [replicas\_low\_evaluation\_window](#input\_replicas\_low\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_replicas_low_no_data_window"></a> [replicas\_low\_no\_data\_window](#input\_replicas\_low\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_replicas_low_threshold_critical"></a> [replicas\_low\_threshold\_critical](#input\_replicas\_low\_threshold\_critical) | Running replica count below which to alert critical. The query compares with `<`, so 1 means alert when no replica is running. Apps with a scale-to-zero rule should disable this monitor rather than lower the threshold | `number` | `1` | no |
| <a name="input_replicas_low_threshold_warning"></a> [replicas\_low\_threshold\_warning](#input\_replicas\_low\_threshold\_warning) | Running replica count below which to alert warning. Above the critical threshold, since this monitor compares with `<` | `number` | `2` | no |
| <a name="input_replicas_low_use_message"></a> [replicas\_low\_use\_message](#input\_replicas\_low\_use\_message) | Whether to use the query alert base message for Container App running replica monitor | `bool` | `false` | no |
| <a name="input_resiliency_ejected_hosts_enabled"></a> [resiliency\_ejected\_hosts\_enabled](#input\_resiliency\_ejected\_hosts\_enabled) | Enable Container App ejected host monitor. Disabled by default: same resiliency-policy feature gate as `resiliency_request_timeouts_enabled` | `bool` | `false` | no |
| <a name="input_resiliency_ejected_hosts_evaluation_window"></a> [resiliency\_ejected\_hosts\_evaluation\_window](#input\_resiliency\_ejected\_hosts\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_resiliency_ejected_hosts_no_data_window"></a> [resiliency\_ejected\_hosts\_no\_data\_window](#input\_resiliency\_ejected\_hosts\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_resiliency_ejected_hosts_threshold_critical"></a> [resiliency\_ejected\_hosts\_threshold\_critical](#input\_resiliency\_ejected\_hosts\_threshold\_critical) | Number of ejected hosts at which to alert critical. Defaults to 0 so that any ejected host alerts, since the query compares with `>` | `number` | `0` | no |
| <a name="input_resiliency_ejected_hosts_use_message"></a> [resiliency\_ejected\_hosts\_use\_message](#input\_resiliency\_ejected\_hosts\_use\_message) | Whether to use the query alert base message for Container App ejected host monitor | `bool` | `false` | no |
| <a name="input_resiliency_request_timeouts_enabled"></a> [resiliency\_request\_timeouts\_enabled](#input\_resiliency\_request\_timeouts\_enabled) | Enable Container App request timeout monitor. Disabled by default: the resiliency metric family is only emitted when a resiliency policy is configured on the app | `bool` | `false` | no |
| <a name="input_resiliency_request_timeouts_evaluation_window"></a> [resiliency\_request\_timeouts\_evaluation\_window](#input\_resiliency\_request\_timeouts\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_resiliency_request_timeouts_no_data_window"></a> [resiliency\_request\_timeouts\_no\_data\_window](#input\_resiliency\_request\_timeouts\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_resiliency_request_timeouts_threshold_critical"></a> [resiliency\_request\_timeouts\_threshold\_critical](#input\_resiliency\_request\_timeouts\_threshold\_critical) | Request timeouts within the evaluation window at which to alert critical | `number` | `10` | no |
| <a name="input_resiliency_request_timeouts_threshold_warning"></a> [resiliency\_request\_timeouts\_threshold\_warning](#input\_resiliency\_request\_timeouts\_threshold\_warning) | Request timeouts within the evaluation window at which to alert warning | `number` | `1` | no |
| <a name="input_resiliency_request_timeouts_use_message"></a> [resiliency\_request\_timeouts\_use\_message](#input\_resiliency\_request\_timeouts\_use\_message) | Whether to use the query alert base message for Container App request timeout monitor | `bool` | `false` | no |
| <a name="input_response_time_high_enabled"></a> [response\_time\_high\_enabled](#input\_response\_time\_high\_enabled) | Enable Container App response time monitor. Azure labels this metric Preview | `bool` | `true` | no |
| <a name="input_response_time_high_evaluation_window"></a> [response\_time\_high\_evaluation\_window](#input\_response\_time\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_response_time_high_no_data_window"></a> [response\_time\_high\_no\_data\_window](#input\_response\_time\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_response_time_high_threshold_critical"></a> [response\_time\_high\_threshold\_critical](#input\_response\_time\_high\_threshold\_critical) | Average response time in MILLISECONDS at which to alert critical. Note the unit: unlike azure/app-service and azure/functions, where `average_response_time` is in seconds, this metric is milliseconds | `number` | `2000` | no |
| <a name="input_response_time_high_threshold_warning"></a> [response\_time\_high\_threshold\_warning](#input\_response\_time\_high\_threshold\_warning) | Average response time in MILLISECONDS at which to alert warning | `number` | `1000` | no |
| <a name="input_response_time_high_use_message"></a> [response\_time\_high\_use\_message](#input\_response\_time\_high\_use\_message) | Whether to use the query alert base message for Container App response time monitor | `bool` | `false` | no |
| <a name="input_restart_count_high_enabled"></a> [restart\_count\_high\_enabled](#input\_restart\_count\_high\_enabled) | Enable Container App replica restart monitor. The metric is cumulative per replica, so the query wraps it in `monotonic_diff()` to alert on the per-interval increase rather than the lifetime total | `bool` | `true` | no |
| <a name="input_restart_count_high_evaluation_window"></a> [restart\_count\_high\_evaluation\_window](#input\_restart\_count\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_restart_count_high_no_data_window"></a> [restart\_count\_high\_no\_data\_window](#input\_restart\_count\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_restart_count_high_threshold_critical"></a> [restart\_count\_high\_threshold\_critical](#input\_restart\_count\_high\_threshold\_critical) | Replica restarts within the evaluation window at which to alert critical | `number` | `5` | no |
| <a name="input_restart_count_high_threshold_warning"></a> [restart\_count\_high\_threshold\_warning](#input\_restart\_count\_high\_threshold\_warning) | Replica restarts within the evaluation window at which to alert warning | `number` | `1` | no |
| <a name="input_restart_count_high_use_message"></a> [restart\_count\_high\_use\_message](#input\_restart\_count\_high\_use\_message) | Whether to use the query alert base message for Container App replica restart monitor | `bool` | `false` | no |
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
