# Requires Terraform >= 1.7 for `mock_provider`, satisfied by the repo's
# .terraform-version pin of latest:^1.9.
mock_provider "datadog" {}

variables {
  notify_default = ["@slack-test"]
}

run "defaults_enable_expected_monitors" {
  command = plan

  assert {
    condition = alltrue([
      length(datadog_monitor.unhealthy_hosts) == 1,
      length(datadog_monitor.healthy_hosts_low) == 1,
      length(datadog_monitor.failed_requests) == 1,
    ])
    error_message = "the three SKU-independent monitors should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.backend_5xx_rate) == 0,
      length(datadog_monitor.backend_latency) == 0,
      length(datadog_monitor.capacity_units_high) == 0,
      length(datadog_monitor.cpu_utilization_high) == 0,
    ])
    error_message = "the unconfirmed-dimension and SKU-specific monitors should be disabled by default"
  }
}

run "queries_target_the_azure_application_gateway_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.network_applicationgateways\\.unhealthy_host_count", datadog_monitor.unhealthy_hosts[0].query))
    error_message = "unhealthy_hosts must query azure.network_applicationgateways.unhealthy_host_count"
  }

  assert {
    condition     = can(regex("azure\\.network_applicationgateways\\.healthy_host_count", datadog_monitor.healthy_hosts_low[0].query))
    error_message = "healthy_hosts_low must query azure.network_applicationgateways.healthy_host_count"
  }

  assert {
    condition     = can(regex("azure\\.network_applicationgateways\\.failed_requests", datadog_monitor.failed_requests[0].query))
    error_message = "failed_requests must query azure.network_applicationgateways.failed_requests"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.unhealthy_hosts[0].query,
        datadog_monitor.healthy_hosts_low[0].query,
        datadog_monitor.failed_requests[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.unhealthy_hosts[0].query,
        datadog_monitor.healthy_hosts_low[0].query,
        datadog_monitor.failed_requests[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

# unhealthy_hosts compares with `>`, so a threshold of 0 is what makes "any
# unhealthy backend alerts" true. A drift to 1 would silently tolerate one dead
# backend.
run "any_occurrence_threshold_is_zero" {
  command = plan

  assert {
    condition     = tonumber(datadog_monitor.unhealthy_hosts[0].monitor_thresholds[0].critical) == 0
    error_message = "unhealthy_hosts must default to 0 so any unhealthy backend alerts"
  }

  assert {
    condition     = can(regex("> 0", datadog_monitor.unhealthy_hosts[0].query))
    error_message = "unhealthy_hosts query must compare against 0"
  }
}

# healthy_hosts_low alerts on a value being too LOW, so its warning threshold
# must sit ABOVE its critical one. Copying a high-side monitor would invert it.
run "below_threshold_monitor_warns_above_critical" {
  command = plan

  assert {
    condition = (
      tonumber(datadog_monitor.healthy_hosts_low[0].monitor_thresholds[0].warning)
      > tonumber(datadog_monitor.healthy_hosts_low[0].monitor_thresholds[0].critical)
    )
    error_message = "healthy_hosts_low warns above its critical threshold because it alerts on a low value"
  }

  assert {
    condition     = can(regex("< 1", datadog_monitor.healthy_hosts_low[0].query))
    error_message = "healthy_hosts_low query must compare with < against the critical threshold"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    backend_5xx_rate_enabled     = true
    backend_latency_enabled      = true
    capacity_units_high_enabled  = true
    cpu_utilization_high_enabled = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.backend_5xx_rate) == 1,
      length(datadog_monitor.backend_latency) == 1,
      length(datadog_monitor.capacity_units_high) == 1,
      length(datadog_monitor.cpu_utilization_high) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.network_applicationgateways\\.backend_connect_time", datadog_monitor.backend_latency[0].query))
    error_message = "backend_latency must query the V2-only backend_connect_time metric"
  }

  assert {
    condition     = can(regex("azure\\.network_applicationgateways\\.cpu_utilization", datadog_monitor.cpu_utilization_high[0].query))
    error_message = "cpu_utilization_high must query the V1-only cpu_utilization metric"
  }
}

# The 5xx numerator splices a status-group tag into local.query_filter rather
# than concatenating, because "{*,tag:5xx}" is not valid Datadog filter syntax.
run "backend_5xx_filter_composes_correctly" {
  command = plan

  variables {
    backend_5xx_rate_enabled = true
  }

  assert {
    condition     = can(regex("backend_response_status\\{httpstatusgroup:5xx\\}", datadog_monitor.backend_5xx_rate[0].query))
    error_message = "with no include/exclude tags the numerator filter must be exactly {httpstatusgroup:5xx}"
  }

  assert {
    condition     = !can(regex("\\{\\*,", datadog_monitor.backend_5xx_rate[0].query))
    error_message = "the wildcard filter must be replaced, not appended to"
  }

  assert {
    condition     = can(regex("total_requests", datadog_monitor.backend_5xx_rate[0].query))
    error_message = "the 5xx rate denominator must be total_requests"
  }
}

run "backend_5xx_status_tag_is_overridable" {
  command = plan

  variables {
    backend_5xx_rate_enabled    = true
    backend_5xx_rate_status_tag = "http_status_group"
  }

  assert {
    condition     = can(regex("backend_response_status\\{http_status_group:5xx\\}", datadog_monitor.backend_5xx_rate[0].query))
    error_message = "the status tag key must be overridable without a module change, since it is unconfirmed"
  }
}

run "backend_5xx_filter_preserves_exclude_tags" {
  command = plan

  variables {
    backend_5xx_rate_enabled = true
    monitor_exclude_tags     = ["env:sandbox"]
  }

  assert {
    condition     = can(regex("httpstatusgroup:5xx", datadog_monitor.backend_5xx_rate[0].query))
    error_message = "the status tag must survive alongside a user-supplied exclude filter"
  }

  assert {
    condition     = can(regex("!env:sandbox", datadog_monitor.backend_5xx_rate[0].query))
    error_message = "splicing must not drop the shared exclude filter"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    unhealthy_hosts_enabled   = false
    healthy_hosts_low_enabled = false
    failed_requests_enabled   = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.unhealthy_hosts) == 0,
      length(datadog_monitor.healthy_hosts_low) == 0,
      length(datadog_monitor.failed_requests) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    failed_requests_threshold_critical   = 25
    failed_requests_threshold_warning    = 5
    healthy_hosts_low_threshold_critical = 2
  }

  assert {
    condition     = can(regex("> 25", datadog_monitor.failed_requests[0].query))
    error_message = "the query comparison must use the critical threshold"
  }

  assert {
    condition     = can(regex("< 2", datadog_monitor.healthy_hosts_low[0].query))
    error_message = "a below-threshold monitor must use its critical threshold in the comparison"
  }
}

run "tags_compose_base_common_and_additional" {
  command = plan

  variables {
    additional_tags = ["extra:tag"]
    env             = "prod"
  }

  assert {
    condition     = contains(datadog_monitor.failed_requests[0].tags, "resource:application-gateway")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.failed_requests[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.failed_requests[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
