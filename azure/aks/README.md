# terraform-datadog-monitor/azure/aks

Configures monitors for Azure Kubernetes Service clusters from **Azure platform metrics**
(`azure.containerservice_managedclusters.*`), covering node saturation, control plane health, pod phase
counts and node readiness.

## This module is a safety net, not Kubernetes monitoring

Read this before deploying it. `azure/aks` watches the cluster and its nodes from the outside, using the
metrics Azure Monitor publishes about the managed cluster resource. It is **not a substitute for running
the Datadog Agent** as a DaemonSet with the Kubernetes integration enabled, and it cannot become one.

What only the Agent can give you, because Azure publishes no platform metric for it:

| Signal | Where it lives |
|---|---|
| Pod restart counts, CrashLoopBackOff | `kubernetes_state.container.restarts` |
| Deployment / statefulset / daemonset replica availability | `kubernetes_state.deployment.replicas_available` vs `.replicas_desired` |
| Container CPU and memory against **requests and limits** | `kubernetes.cpu.usage.total`, `kubernetes.memory.usage` and the `kubernetes_state` limit metrics |
| OOMKill events | `kubernetes.containers.state.terminated` with `reason:oomkilled` |
| Horizontal Pod Autoscaler state | `kubernetes_state.hpa.*` |
| Per-pod and per-container resource attribution | Agent tagging |

The platform metrics in this module are node-level and cluster-level only. A cluster can be entirely green
here while a single deployment is crash-looping, because nothing in
`azure.containerservice_managedclusters.*` counts restarts.

If you want restart and replica coverage from platform metrics rather than the Agent, that exists for
**Azure Container Apps**, not AKS: see `azure/container-apps`, where `restart_count` and `replicas` are
first-class metrics.

## Monitors that depend on unconfirmed Datadog tags

Three monitors ship **enabled** while resting on a tag key and value pair that has **not** been confirmed
against live data. Read this section before trusting them.

Datadog's Azure integration maps Azure Monitor dimensions to Datadog tags: "Metrics are collected with all
available dimensions (which are mapped to tags in Datadog)". What is not documented is how the resulting
tag key is spelled, or whether tag values keep their source casing. Azure names these dimensions in
lowercase, which is reassuring for the keys, but Kubernetes capitalises the **values** (`Failed`,
`Pending`, `Ready`) and Datadog normalises tag values to lowercase in some integrations.

| Monitor | Filter it applies | Variables to correct it |
|---|---|---|
| `pods_failed` | `{phase:Failed}` | `pods_failed_phase_tag_key`, `pods_failed_phase_tag_value` |
| `pods_pending` | `{phase:Pending}` | `pods_pending_phase_tag_key`, `pods_pending_phase_tag_value` |
| `nodes_not_ready` | `{condition:Ready,status:false}` | `nodes_not_ready_condition_tag_key`, `nodes_not_ready_condition_tag_value`, `nodes_not_ready_status_tag_key`, `nodes_not_ready_status_tag_value` |

**If a key or value is wrong the query returns no data, and because `notify_no_data` defaults to `false`
that failure is silent.** A silently dead monitor reads as coverage while providing none, which is worse
than an absent one. So on a first deployment:

1. Open the Datadog metric explorer, query
   `azure.containerservice_managedclusters.kube_pod_status_phase`, and read the real tag key and values off
   the live series.
2. Set the variables above to match. They exist precisely so a wrong guess is a tfvars fix rather than a
   module release.
3. Consider setting `notify_no_data = true` for the first few days so a wrong pair announces itself instead
   of failing quietly.

`nodes_not_ready` is the most fragile monitor here, since it depends on two pairs rather than one.

## Thresholds worth knowing about

- **`node_disk_high` defaults to 85 / 75**, lower than the 90 / 80 used for CPU and memory. This is
  deliberate: the kubelet begins evicting pods under disk pressure, and a genuinely full node disk can stop
  the kubelet reporting at all, so 90 is already too late.
- **`etcd_database_usage_high` warns at 75** while alerting critical at 90. When the etcd database reaches
  its quota the cluster goes **read-only**, and recovery means finding and deleting objects, which takes
  time to organise. This is the highest-value monitor in the module: etcd database growth is driven by the
  client's own object count and size, so unlike the rest of the control plane it is genuinely actionable.
- **`pods_pending` uses a 15 minute window**, longer than the module default. Pods sit in Pending routinely
  while images pull and volumes attach. What matters is pods *staying* pending, not passing through.
- **`pods_failed` and `nodes_not_ready` default to a critical threshold of 0** and compare with `>`, so any
  single occurrence alerts.

## Monitors disabled by default

| Monitor | Why |
|---|---|
| `unschedulable_pods` | The `cluster_autoscaler_*` metrics are only emitted when the cluster autoscaler is enabled on the cluster. Enable alongside it. |
| `autoscaler_unhealthy` | Same cluster-autoscaler gate. |
| `etcd_cpu_high` | Not a feature gate. Azure operates and scales the AKS control plane, so etcd CPU is not customer-actionable the way etcd *database* usage is. Enable for visibility, but expect to be unable to act on it. |

## A note on Azure's PREVIEW labelling

Microsoft files every `node_*` metric under a "Nodes (PREVIEW)" category, and all four
`cluster_autoscaler_*` metrics under "Cluster Autoscaler (PREVIEW)". The GA categories are API Server
(CPU and memory), ETCD, Nodes (`kube_node_status_*`) and Pods (`kube_pod_status_*`).

This module does **not** disable a monitor merely because Microsoft labels it preview. Doing so would leave
almost nothing enabled, and Microsoft's own [Azure Monitor Baseline
Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/ContainerService/managedClusters/)
ship `node_cpu_usage_percentage`, `node_memory_working_set_percentage` and `node_disk_usage_percentage`
enabled. What does disable a monitor here is a feature gate, as in the table above. The labelling is
recorded so nobody is surprised if Microsoft changes it.

## Metrics deliberately not modelled

`kube_node_status_allocatable_cpu_cores` and `kube_node_status_allocatable_memory_bytes` are capacity
gauges rather than alertable conditions. The absolute-value counterparts of the percentage metrics
(`node_cpu_usage_millicores`, `node_disk_usage_bytes`, `node_memory_*_bytes`, `node_network_in_bytes`,
`node_network_out_bytes`) are omitted because a byte threshold is meaningless without knowing the node SKU.
`node_memory_rss_percentage` is redundant with working set, which is what the kubelet evicts on.
`etcd_memory_usage_percentage` falls to the same argument as `etcd_cpu_high`.
`apiserver_current_inflight_requests` is preview *and* its `requestKind` dimension is the only camelCase
key in the AKS set, so it carries the highest tag-spelling risk. `kube_pod_status_ready` would need a ratio
against total pods, meaning two metrics and two more unconfirmed tag pairs; that is Agent territory.
`cluster_autoscaler_scale_down_in_cooldown` and `cluster_autoscaler_unneeded_nodes_count` are informational
autoscaler state. `count` is resource inventory, not health.

## Group by

```
by {name,subscription_name,resource_group,region,env,datadog_managed}
```

`nodepool` would be a useful split, separating system from user node pools, but it is an unconfirmed tag
and grouping by a tag that does not exist fragments every series into an `N/A` group. Confirm it against
live data first; adding it is then a one-line change.

## Running the tests

Unit tests live in `tests/` and assert monitor toggles, metric namespaces, group-by tags, threshold
plumbing and tag composition against a mocked Datadog provider (no API access needed). Module-specific
guards check that the dimension splice preserves user-supplied exclude tags, that the `{*}` wildcard is
replaced rather than concatenated, that the tag keys and values are genuinely overridable, and that no
query reaches into the Datadog Agent's `kubernetes*` namespaces.

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
| [datadog_monitor.apiserver_cpu_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.apiserver_memory_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.autoscaler_unhealthy](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.etcd_cpu_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.etcd_database_usage_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.node_cpu_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.node_disk_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.node_memory_working_set_high](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.nodes_not_ready](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.pods_failed](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.pods_pending](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.unschedulable_pods](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (key:value format) to add to this type of check (combined with `local.tags` and `var.base_tags`) | `list(string)` | `[]` | no |
| <a name="input_alert_critical_priority"></a> [alert\_critical\_priority](#input\_alert\_critical\_priority) | Priority for alerts within critical threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Message to prepend to alert notifications | `string` | `"Alert"` | no |
| <a name="input_alert_nodata_priority"></a> [alert\_nodata\_priority](#input\_alert\_nodata\_priority) | Priority for alerts within warning threshold (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |
| <a name="input_apiserver_cpu_high_enabled"></a> [apiserver\_cpu\_high\_enabled](#input\_apiserver\_cpu\_high\_enabled) | Enable AKS API server CPU utilization monitor. A throttled API server stalls every controller in the cluster | `bool` | `true` | no |
| <a name="input_apiserver_cpu_high_evaluation_window"></a> [apiserver\_cpu\_high\_evaluation\_window](#input\_apiserver\_cpu\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_apiserver_cpu_high_no_data_window"></a> [apiserver\_cpu\_high\_no\_data\_window](#input\_apiserver\_cpu\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_apiserver_cpu_high_threshold_critical"></a> [apiserver\_cpu\_high\_threshold\_critical](#input\_apiserver\_cpu\_high\_threshold\_critical) | API server CPU utilization percentage (against its current limit) at which to alert critical | `number` | `90` | no |
| <a name="input_apiserver_cpu_high_threshold_warning"></a> [apiserver\_cpu\_high\_threshold\_warning](#input\_apiserver\_cpu\_high\_threshold\_warning) | API server CPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_apiserver_cpu_high_use_message"></a> [apiserver\_cpu\_high\_use\_message](#input\_apiserver\_cpu\_high\_use\_message) | Whether to use the query alert base message for AKS API server CPU utilization monitor | `bool` | `false` | no |
| <a name="input_apiserver_memory_high_enabled"></a> [apiserver\_memory\_high\_enabled](#input\_apiserver\_memory\_high\_enabled) | Enable AKS API server memory utilization monitor | `bool` | `true` | no |
| <a name="input_apiserver_memory_high_evaluation_window"></a> [apiserver\_memory\_high\_evaluation\_window](#input\_apiserver\_memory\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_apiserver_memory_high_no_data_window"></a> [apiserver\_memory\_high\_no\_data\_window](#input\_apiserver\_memory\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_apiserver_memory_high_threshold_critical"></a> [apiserver\_memory\_high\_threshold\_critical](#input\_apiserver\_memory\_high\_threshold\_critical) | API server memory utilization percentage (against its current limit) at which to alert critical | `number` | `90` | no |
| <a name="input_apiserver_memory_high_threshold_warning"></a> [apiserver\_memory\_high\_threshold\_warning](#input\_apiserver\_memory\_high\_threshold\_warning) | API server memory utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_apiserver_memory_high_use_message"></a> [apiserver\_memory\_high\_use\_message](#input\_apiserver\_memory\_high\_use\_message) | Whether to use the query alert base message for AKS API server memory utilization monitor | `bool` | `false` | no |
| <a name="input_autoscaler_unhealthy_enabled"></a> [autoscaler\_unhealthy\_enabled](#input\_autoscaler\_unhealthy\_enabled) | Enable AKS cluster autoscaler health monitor. Disabled by default: same cluster-autoscaler feature gate as `unschedulable_pods_enabled` | `bool` | `false` | no |
| <a name="input_autoscaler_unhealthy_evaluation_window"></a> [autoscaler\_unhealthy\_evaluation\_window](#input\_autoscaler\_unhealthy\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_autoscaler_unhealthy_no_data_window"></a> [autoscaler\_unhealthy\_no\_data\_window](#input\_autoscaler\_unhealthy\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_autoscaler_unhealthy_threshold_critical"></a> [autoscaler\_unhealthy\_threshold\_critical](#input\_autoscaler\_unhealthy\_threshold\_critical) | Value below which to alert critical. The metric reports 1 when the autoscaler considers the cluster safe to act on, so the query compares with `<` | `number` | `1` | no |
| <a name="input_autoscaler_unhealthy_use_message"></a> [autoscaler\_unhealthy\_use\_message](#input\_autoscaler\_unhealthy\_use\_message) | Whether to use the query alert base message for AKS cluster autoscaler health monitor | `bool` | `false` | no |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags (key:value format) to add to this type of check (combined with `local.tags` and `var.additional_tags`, generally you should not change this) | `list(string)` | <pre>[<br>  "resource:aks"<br>]</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost Center of the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_dashboard_link"></a> [dashboard\_link](#input\_dashboard\_link) | Dashboard link to include in message | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment the monitored resource is in (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_etcd_cpu_high_enabled"></a> [etcd\_cpu\_high\_enabled](#input\_etcd\_cpu\_high\_enabled) | Enable AKS etcd CPU utilization monitor. Disabled by default, and not because of a feature gate: Azure operates and scales the AKS control plane, so etcd CPU is not customer-actionable the way etcd database usage is | `bool` | `false` | no |
| <a name="input_etcd_cpu_high_evaluation_window"></a> [etcd\_cpu\_high\_evaluation\_window](#input\_etcd\_cpu\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_etcd_cpu_high_no_data_window"></a> [etcd\_cpu\_high\_no\_data\_window](#input\_etcd\_cpu\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_etcd_cpu_high_threshold_critical"></a> [etcd\_cpu\_high\_threshold\_critical](#input\_etcd\_cpu\_high\_threshold\_critical) | etcd CPU utilization percentage (against its current limit) at which to alert critical | `number` | `90` | no |
| <a name="input_etcd_cpu_high_threshold_warning"></a> [etcd\_cpu\_high\_threshold\_warning](#input\_etcd\_cpu\_high\_threshold\_warning) | etcd CPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_etcd_cpu_high_use_message"></a> [etcd\_cpu\_high\_use\_message](#input\_etcd\_cpu\_high\_use\_message) | Whether to use the query alert base message for AKS etcd CPU utilization monitor | `bool` | `false` | no |
| <a name="input_etcd_database_usage_high_enabled"></a> [etcd\_database\_usage\_high\_enabled](#input\_etcd\_database\_usage\_high\_enabled) | Enable AKS etcd database usage monitor. The highest-value monitor in this module: etcd database usage is driven by the client's own object count and size, and at quota the cluster goes read-only | `bool` | `true` | no |
| <a name="input_etcd_database_usage_high_evaluation_window"></a> [etcd\_database\_usage\_high\_evaluation\_window](#input\_etcd\_database\_usage\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_etcd_database_usage_high_no_data_window"></a> [etcd\_database\_usage\_high\_no\_data\_window](#input\_etcd\_database\_usage\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_etcd_database_usage_high_threshold_critical"></a> [etcd\_database\_usage\_high\_threshold\_critical](#input\_etcd\_database\_usage\_high\_threshold\_critical) | etcd database usage percentage at which to alert critical | `number` | `90` | no |
| <a name="input_etcd_database_usage_high_threshold_warning"></a> [etcd\_database\_usage\_high\_threshold\_warning](#input\_etcd\_database\_usage\_high\_threshold\_warning) | etcd database usage percentage at which to alert warning. Deliberately well below the critical threshold: recovering from a full etcd means deleting objects, which takes time to organize | `number` | `75` | no |
| <a name="input_etcd_database_usage_high_use_message"></a> [etcd\_database\_usage\_high\_use\_message](#input\_etcd\_database\_usage\_high\_use\_message) | Whether to use the query alert base message for AKS etcd database usage monitor | `bool` | `false` | no |
| <a name="input_evaluation_delay"></a> [evaluation\_delay](#input\_evaluation\_delay) | Monitor evaluation delay (see [https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#set-alert-conditions](Datadog Docs)) | `number` | `900` | no |
| <a name="input_group_by"></a> [group\_by](#input\_group\_by) | List of tags to group by | `list(string)` | <pre>[<br>  "name",<br>  "aws_account",<br>  "env",<br>  "datadog_managed"<br>]</pre> | no |
| <a name="input_monitor_exclude_tags"></a> [monitor\_exclude\_tags](#input\_monitor\_exclude\_tags) | Tags to be excluded in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_monitor_include_tags"></a> [monitor\_include\_tags](#input\_monitor\_include\_tags) | Tags to be included in the monitoring query. Specify in key:value format | `list(string)` | `[]` | no |
| <a name="input_new_group_delay"></a> [new\_group\_delay](#input\_new\_group\_delay) | Delay in seconds before generating alerts for a new resource | `number` | `300` | no |
| <a name="input_node_cpu_high_enabled"></a> [node\_cpu\_high\_enabled](#input\_node\_cpu\_high\_enabled) | Enable AKS node CPU utilization monitor | `bool` | `true` | no |
| <a name="input_node_cpu_high_evaluation_window"></a> [node\_cpu\_high\_evaluation\_window](#input\_node\_cpu\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_node_cpu_high_no_data_window"></a> [node\_cpu\_high\_no\_data\_window](#input\_node\_cpu\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_node_cpu_high_threshold_critical"></a> [node\_cpu\_high\_threshold\_critical](#input\_node\_cpu\_high\_threshold\_critical) | Aggregated node CPU utilization percentage at which to alert critical | `number` | `90` | no |
| <a name="input_node_cpu_high_threshold_warning"></a> [node\_cpu\_high\_threshold\_warning](#input\_node\_cpu\_high\_threshold\_warning) | Aggregated node CPU utilization percentage at which to alert warning | `number` | `80` | no |
| <a name="input_node_cpu_high_use_message"></a> [node\_cpu\_high\_use\_message](#input\_node\_cpu\_high\_use\_message) | Whether to use the query alert base message for AKS node CPU utilization monitor | `bool` | `false` | no |
| <a name="input_node_disk_high_enabled"></a> [node\_disk\_high\_enabled](#input\_node\_disk\_high\_enabled) | Enable AKS node disk usage monitor | `bool` | `true` | no |
| <a name="input_node_disk_high_evaluation_window"></a> [node\_disk\_high\_evaluation\_window](#input\_node\_disk\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_node_disk_high_no_data_window"></a> [node\_disk\_high\_no\_data\_window](#input\_node\_disk\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_node_disk_high_threshold_critical"></a> [node\_disk\_high\_threshold\_critical](#input\_node\_disk\_high\_threshold\_critical) | Node disk usage percentage at which to alert critical. Lower than the CPU and memory defaults on purpose: the kubelet begins evicting pods under disk pressure and can stop reporting entirely on a full disk, so 90 would be too late | `number` | `85` | no |
| <a name="input_node_disk_high_threshold_warning"></a> [node\_disk\_high\_threshold\_warning](#input\_node\_disk\_high\_threshold\_warning) | Node disk usage percentage at which to alert warning | `number` | `75` | no |
| <a name="input_node_disk_high_use_message"></a> [node\_disk\_high\_use\_message](#input\_node\_disk\_high\_use\_message) | Whether to use the query alert base message for AKS node disk usage monitor | `bool` | `false` | no |
| <a name="input_node_memory_working_set_high_enabled"></a> [node\_memory\_working\_set\_high\_enabled](#input\_node\_memory\_working\_set\_high\_enabled) | Enable AKS node memory working set monitor. Working set rather than RSS because the kubelet evicts pods based on working set memory | `bool` | `true` | no |
| <a name="input_node_memory_working_set_high_evaluation_window"></a> [node\_memory\_working\_set\_high\_evaluation\_window](#input\_node\_memory\_working\_set\_high\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_node_memory_working_set_high_no_data_window"></a> [node\_memory\_working\_set\_high\_no\_data\_window](#input\_node\_memory\_working\_set\_high\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_node_memory_working_set_high_threshold_critical"></a> [node\_memory\_working\_set\_high\_threshold\_critical](#input\_node\_memory\_working\_set\_high\_threshold\_critical) | Node memory working set percentage at which to alert critical | `number` | `90` | no |
| <a name="input_node_memory_working_set_high_threshold_warning"></a> [node\_memory\_working\_set\_high\_threshold\_warning](#input\_node\_memory\_working\_set\_high\_threshold\_warning) | Node memory working set percentage at which to alert warning | `number` | `80` | no |
| <a name="input_node_memory_working_set_high_use_message"></a> [node\_memory\_working\_set\_high\_use\_message](#input\_node\_memory\_working\_set\_high\_use\_message) | Whether to use the query alert base message for AKS node memory working set monitor | `bool` | `false` | no |
| <a name="input_nodes_not_ready_condition_tag_key"></a> [nodes\_not\_ready\_condition\_tag\_key](#input\_nodes\_not\_ready\_condition\_tag\_key) | Datadog tag key carrying the node condition type. Azure names the dimension `condition`; NOT confirmed against live data | `string` | `"condition"` | no |
| <a name="input_nodes_not_ready_condition_tag_value"></a> [nodes\_not\_ready\_condition\_tag\_value](#input\_nodes\_not\_ready\_condition\_tag\_value) | Datadog tag value identifying the Ready node condition. Kubernetes capitalises condition names; set to `ready` if the capitalised form returns no data | `string` | `"Ready"` | no |
| <a name="input_nodes_not_ready_enabled"></a> [nodes\_not\_ready\_enabled](#input\_nodes\_not\_ready\_enabled) | Enable AKS nodes-not-ready monitor. NOTE: this is the most fragile monitor in the module, depending on TWO unconfirmed dimension tag pairs (condition and status). Confirm both against live data | `bool` | `true` | no |
| <a name="input_nodes_not_ready_evaluation_window"></a> [nodes\_not\_ready\_evaluation\_window](#input\_nodes\_not\_ready\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_nodes_not_ready_no_data_window"></a> [nodes\_not\_ready\_no\_data\_window](#input\_nodes\_not\_ready\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_nodes_not_ready_status_tag_key"></a> [nodes\_not\_ready\_status\_tag\_key](#input\_nodes\_not\_ready\_status\_tag\_key) | Datadog tag key carrying the node condition status. Azure names the dimension `status`; NOT confirmed against live data | `string` | `"status"` | no |
| <a name="input_nodes_not_ready_status_tag_value"></a> [nodes\_not\_ready\_status\_tag\_value](#input\_nodes\_not\_ready\_status\_tag\_value) | Datadog tag value identifying a condition that is NOT met. Combined with the condition key this selects nodes whose Ready condition is false | `string` | `"false"` | no |
| <a name="input_nodes_not_ready_threshold_critical"></a> [nodes\_not\_ready\_threshold\_critical](#input\_nodes\_not\_ready\_threshold\_critical) | Number of not-ready nodes at which to alert critical. Defaults to 0 so that any not-ready node alerts, since the query compares with `>` | `number` | `0` | no |
| <a name="input_nodes_not_ready_use_message"></a> [nodes\_not\_ready\_use\_message](#input\_nodes\_not\_ready\_use\_message) | Whether to use the query alert base message for AKS nodes-not-ready monitor | `bool` | `false` | no |
| <a name="input_notify_alert_override"></a> [notify\_alert\_override](#input\_notify\_alert\_override) | List of notifications for alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_crit_override"></a> [notify\_crit\_override](#input\_notify\_crit\_override) | List of notifications for 24x7 alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_default"></a> [notify\_default](#input\_notify\_default) | List of alert notifications (can be overridden based on alert type) | `list(string)` | n/a | yes |
| <a name="input_notify_no_data"></a> [notify\_no\_data](#input\_notify\_no\_data) | Alert if no matching data is found | `bool` | `false` | no |
| <a name="input_notify_nodata_override"></a> [notify\_nodata\_override](#input\_notify\_nodata\_override) | List of notifications for no data (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_nonprod_override"></a> [notify\_nonprod\_override](#input\_notify\_nonprod\_override) | List of notifications for non-prod alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_prod_override"></a> [notify\_prod\_override](#input\_notify\_prod\_override) | List of notifications for 12x5 prod alerts in critical threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_recovery_override"></a> [notify\_recovery\_override](#input\_notify\_recovery\_override) | List of notifications for alert recovery (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_notify_warn_override"></a> [notify\_warn\_override](#input\_notify\_warn\_override) | List of notifications for alerts in warning threshold (uses `notify_default` otherwise) | `list(string)` | `[]` | no |
| <a name="input_pods_failed_enabled"></a> [pods\_failed\_enabled](#input\_pods\_failed\_enabled) | Enable AKS failed pods monitor. NOTE: `kube_pod_status_phase` reports every phase under one metric name discriminated by a dimension, so this query depends on the Datadog tag key AND value for that dimension. Neither is confirmed against live data. If either is wrong the query silently returns nothing | `bool` | `true` | no |
| <a name="input_pods_failed_evaluation_window"></a> [pods\_failed\_evaluation\_window](#input\_pods\_failed\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_5m"` | no |
| <a name="input_pods_failed_no_data_window"></a> [pods\_failed\_no\_data\_window](#input\_pods\_failed\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_pods_failed_phase_tag_key"></a> [pods\_failed\_phase\_tag\_key](#input\_pods\_failed\_phase\_tag\_key) | Datadog tag key carrying the pod phase. Azure names the dimension `phase`; this is the expected Datadog key but has NOT been confirmed against live data. Exposed as a variable so it can be corrected without a module change | `string` | `"phase"` | no |
| <a name="input_pods_failed_phase_tag_value"></a> [pods\_failed\_phase\_tag\_value](#input\_pods\_failed\_phase\_tag\_value) | Datadog tag value identifying the failed pod phase. Kubernetes capitalises phase names (`Failed`), but Datadog normalises tag values to lowercase in some integrations. Whether it does here is NOT confirmed; set to `failed` if the capitalised form returns no data | `string` | `"Failed"` | no |
| <a name="input_pods_failed_threshold_critical"></a> [pods\_failed\_threshold\_critical](#input\_pods\_failed\_threshold\_critical) | Number of failed pods at which to alert critical. Defaults to 0 so that any failed pod alerts, since the query compares with `>` | `number` | `0` | no |
| <a name="input_pods_failed_use_message"></a> [pods\_failed\_use\_message](#input\_pods\_failed\_use\_message) | Whether to use the query alert base message for AKS failed pods monitor | `bool` | `false` | no |
| <a name="input_pods_pending_enabled"></a> [pods\_pending\_enabled](#input\_pods\_pending\_enabled) | Enable AKS pending pods monitor. Same unconfirmed-dimension caveat as `pods_failed_enabled` | `bool` | `true` | no |
| <a name="input_pods_pending_evaluation_window"></a> [pods\_pending\_evaluation\_window](#input\_pods\_pending\_evaluation\_window) | Evaluation window for monitor. Longer than the module default on purpose: pods sit in Pending routinely while images pull and volumes attach, so a short window alerts on healthy scheduling churn. What matters is pods staying pending | `string` | `"last_15m"` | no |
| <a name="input_pods_pending_no_data_window"></a> [pods\_pending\_no\_data\_window](#input\_pods\_pending\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_pods_pending_phase_tag_key"></a> [pods\_pending\_phase\_tag\_key](#input\_pods\_pending\_phase\_tag\_key) | Datadog tag key carrying the pod phase. Not confirmed against live data; see `pods_failed_phase_tag_key` | `string` | `"phase"` | no |
| <a name="input_pods_pending_phase_tag_value"></a> [pods\_pending\_phase\_tag\_value](#input\_pods\_pending\_phase\_tag\_value) | Datadog tag value identifying the pending pod phase. Not confirmed against live data; set to `pending` if the capitalised form returns no data | `string` | `"Pending"` | no |
| <a name="input_pods_pending_threshold_critical"></a> [pods\_pending\_threshold\_critical](#input\_pods\_pending\_threshold\_critical) | Number of pending pods at which to alert critical. A guess tuned for a generic cluster; confirm against real scheduling churn | `number` | `5` | no |
| <a name="input_pods_pending_threshold_warning"></a> [pods\_pending\_threshold\_warning](#input\_pods\_pending\_threshold\_warning) | Number of pending pods at which to alert warning | `number` | `1` | no |
| <a name="input_pods_pending_use_message"></a> [pods\_pending\_use\_message](#input\_pods\_pending\_use\_message) | Whether to use the query alert base message for AKS pending pods monitor | `bool` | `false` | no |
| <a name="input_renotify_interval"></a> [renotify\_interval](#input\_renotify\_interval) | Interval in minutes to re-send notifications about an alert | `number` | `60` | no |
| <a name="input_runbook_link"></a> [runbook\_link](#input\_runbook\_link) | Runbook link to include in message | `string` | `null` | no |
| <a name="input_service"></a> [service](#input\_service) | Service associated with the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_team"></a> [team](#input\_team) | Team supporting the monitored resource (leave blank to omit tag) | `string` | `null` | no |
| <a name="input_timeout_h"></a> [timeout\_h](#input\_timeout\_h) | Auto-resolve alert in specified hours if condition no longer matches | `number` | `0` | no |
| <a name="input_title_prefix"></a> [title\_prefix](#input\_title\_prefix) | Prefix all alerts with specified value in brackets | `string` | `null` | no |
| <a name="input_title_suffix"></a> [title\_suffix](#input\_title\_suffix) | Suffix all alerts with specified value in parenthesis | `string` | `null` | no |
| <a name="input_unschedulable_pods_enabled"></a> [unschedulable\_pods\_enabled](#input\_unschedulable\_pods\_enabled) | Enable AKS unschedulable pods monitor. Disabled by default: the `cluster_autoscaler_*` metrics are only emitted when the cluster autoscaler is enabled on the cluster | `bool` | `false` | no |
| <a name="input_unschedulable_pods_evaluation_window"></a> [unschedulable\_pods\_evaluation\_window](#input\_unschedulable\_pods\_evaluation\_window) | Evaluation window for monitor (`last_?m` (1, 5, 10, 15, or 30), `last_?h` (1, 2, or 4), or `last_1d`] | `string` | `"last_15m"` | no |
| <a name="input_unschedulable_pods_no_data_window"></a> [unschedulable\_pods\_no\_data\_window](#input\_unschedulable\_pods\_no\_data\_window) | No data threshold (in minutes, 0 to disable) | `number` | `10` | no |
| <a name="input_unschedulable_pods_threshold_critical"></a> [unschedulable\_pods\_threshold\_critical](#input\_unschedulable\_pods\_threshold\_critical) | Number of unschedulable pods at which to alert critical. Defaults to 0 so that any unschedulable pod alerts, since the query compares with `>` | `number` | `0` | no |
| <a name="input_unschedulable_pods_use_message"></a> [unschedulable\_pods\_use\_message](#input\_unschedulable\_pods\_use\_message) | Whether to use the query alert base message for AKS unschedulable pods monitor | `bool` | `false` | no |
| <a name="input_warn_priority"></a> [warn\_priority](#input\_warn\_priority) | Priority for alerts with no data (P1-P5, uses monitor defaults if not specified) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
