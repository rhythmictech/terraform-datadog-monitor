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
      length(datadog_monitor.restart_count_high) == 1,
      length(datadog_monitor.replicas_low) == 1,
      length(datadog_monitor.cpu_high) == 1,
      length(datadog_monitor.memory_high) == 1,
      length(datadog_monitor.response_time_high) == 1,
      length(datadog_monitor.http_5xx_rate) == 1,
    ])
    error_message = "the six default monitors should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.cold_start_high) == 0,
      length(datadog_monitor.resiliency_request_timeouts) == 0,
      length(datadog_monitor.resiliency_ejected_hosts) == 0,
      length(datadog_monitor.gpu_utilization_high) == 0,
    ])
    error_message = "the agent-gated, resiliency-policy-gated and GPU-gated monitors should be disabled by default"
  }
}

run "queries_target_the_container_apps_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.restart_count", datadog_monitor.restart_count_high[0].query))
    error_message = "restart_count_high must query azure.app_containerapps.restart_count"
  }

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.replicas", datadog_monitor.replicas_low[0].query))
    error_message = "replicas_low must query azure.app_containerapps.replicas"
  }

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.cpu_percentage", datadog_monitor.cpu_high[0].query))
    error_message = "cpu_high must query azure.app_containerapps.cpu_percentage"
  }

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.memory_percentage", datadog_monitor.memory_high[0].query))
    error_message = "memory_high must query azure.app_containerapps.memory_percentage"
  }

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.response_time", datadog_monitor.response_time_high[0].query))
    error_message = "response_time_high must query azure.app_containerapps.response_time"
  }

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.requests", datadog_monitor.http_5xx_rate[0].query))
    error_message = "http_5xx_rate must query azure.app_containerapps.requests for both numerator and denominator"
  }
}

# `restart_count` is a CUMULATIVE per-replica counter. Alerting on the raw value
# latches: once a replica crosses the threshold the monitor stays triggered for
# that replica's whole life, and a replica that restarted six times over three
# months scores identically to one crash-looping right now. Dropping the wrapper
# is an easy and invisible regression.
run "restart_count_is_wrapped_in_monotonic_diff" {
  command = plan

  assert {
    condition     = can(regex("monotonic_diff\\(", datadog_monitor.restart_count_high[0].query))
    error_message = "restart_count_high must wrap the cumulative counter in monotonic_diff() so it alerts on the per-interval increase"
  }

  assert {
    condition     = can(regex("monotonic_diff\\(max:azure\\.app_containerapps\\.restart_count", datadog_monitor.restart_count_high[0].query))
    error_message = "monotonic_diff() must wrap the restart_count metric itself, not something else in the query"
  }
}

# The one metric here whose namespace has no `app_` infix. Datadog documents it as
# azure.containerapps.enhanced.cold_start, and "correcting" it to
# azure.app_containerapps.enhanced.cold_start yields a metric that does not exist.
run "cold_start_uses_the_enhanced_namespace_without_app_infix" {
  command = plan

  variables {
    cold_start_high_enabled = true
  }

  assert {
    condition     = can(regex("azure\\.containerapps\\.enhanced\\.cold_start", datadog_monitor.cold_start_high[0].query))
    error_message = "cold_start_high must query azure.containerapps.enhanced.cold_start"
  }

  assert {
    condition     = !can(regex("azure\\.app_containerapps\\.enhanced", datadog_monitor.cold_start_high[0].query))
    error_message = "the enhanced namespace has no app_ infix; azure.app_containerapps.enhanced.* does not exist"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.restart_count_high[0].query,
        datadog_monitor.replicas_low[0].query,
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.memory_high[0].query,
        datadog_monitor.response_time_high[0].query,
        datadog_monitor.http_5xx_rate[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.restart_count_high[0].query,
        datadog_monitor.replicas_low[0].query,
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.memory_high[0].query,
        datadog_monitor.response_time_high[0].query,
        datadog_monitor.http_5xx_rate[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

# local.query_filter from common.tf renders complete with braces, so the status
# class has to be spliced INSIDE the closing brace. This also checks that only
# the NUMERATOR carries the status filter: a denominator scoped to 5xx would make
# the rate always 100 percent.
run "dimension_splice_preserves_exclude_tags" {
  command = plan

  variables {
    monitor_exclude_tags = ["revision:canary"]
  }

  assert {
    condition = alltrue([
      can(regex("!revision:canary", datadog_monitor.http_5xx_rate[0].query)),
      can(regex("statuscodecategory:5xx", datadog_monitor.http_5xx_rate[0].query)),
    ])
    error_message = "the spliced filter must keep the user's exclude tag alongside the status class filter"
  }

  assert {
    condition     = !can(regex("\\{\\*,", datadog_monitor.http_5xx_rate[0].query))
    error_message = "the wildcard must never be concatenated with a dimension tag: {*,tag:value} is invalid Datadog syntax"
  }

  assert {
    condition     = length(regexall("statuscodecategory:5xx", datadog_monitor.http_5xx_rate[0].query)) == 1
    error_message = "only the numerator may filter on the status class; a 5xx-scoped denominator would make the rate always 100 percent"
  }
}

# The run above deliberately sets monitor_exclude_tags, which means
# local.query_filter is NOT "{*}" there and the wildcard branch of the splice is
# never exercised by it. This run must therefore set NO filter variables: with no
# include or exclude tags common.tf renders local.query_filter as exactly "{*}",
# and the status filter has to REPLACE that wildcard rather than be appended to
# it, because "{*,statuscodecategory:5xx}" is invalid Datadog syntax.
run "wildcard_filter_is_replaced_not_concatenated" {
  command = plan

  assert {
    condition     = !can(regex("\\{\\*,", datadog_monitor.http_5xx_rate[0].query))
    error_message = "with no include or exclude tags the status filter must replace the {*} wildcard, not be concatenated with it"
  }

  assert {
    condition     = can(regex("requests\\{statuscodecategory:5xx\\}", datadog_monitor.http_5xx_rate[0].query))
    error_message = "the default numerator filter must be exactly the status class selector"
  }

  # The denominator, and every non-dimension monitor, must still carry the plain
  # wildcard, so the assertion above cannot be satisfied by dropping the filter.
  assert {
    condition = alltrue([
      can(regex("requests\\{\\*\\}", datadog_monitor.http_5xx_rate[0].query)),
      can(regex("cpu_percentage\\{\\*\\}", datadog_monitor.cpu_high[0].query)),
    ])
    error_message = "the rate denominator and non-dimension monitors must still render the {*} wildcard filter"
  }
}

# The containment story for shipping http_5xx_rate enabled while its tag pair is
# unconfirmed, and this is the highest-risk pair in either module because Azure
# spells the dimension in camelCase.
run "dimension_tag_keys_and_values_are_overridable" {
  command = plan

  variables {
    http_5xx_rate_status_tag_key   = "statusCodeCategory"
    http_5xx_rate_status_tag_value = "ServerError"
  }

  assert {
    condition     = can(regex("statusCodeCategory:ServerError", datadog_monitor.http_5xx_rate[0].query))
    error_message = "overriding both the status tag key and value must reach the query"
  }
}

# replicas_low compares with `<`, so its warning threshold must sit ABOVE the
# critical one or the warning can never fire.
run "replicas_low_keeps_warning_above_critical" {
  command = plan

  assert {
    condition = (
      tonumber(datadog_monitor.replicas_low[0].monitor_thresholds[0].warning) >
      tonumber(datadog_monitor.replicas_low[0].monitor_thresholds[0].critical)
    )
    error_message = "a below-threshold monitor must keep its warning above its critical threshold"
  }

  assert {
    condition     = can(regex("< 1", datadog_monitor.replicas_low[0].query))
    error_message = "replicas_low must compare with < so it alerts when no replica is running"
  }
}

# Milliseconds, not seconds. azure/app-service and azure/functions use
# average_response_time in SECONDS with a default of 5, so a 5 here would mean
# alerting at five milliseconds.
run "response_time_thresholds_are_in_milliseconds" {
  command = plan

  assert {
    condition     = tonumber(datadog_monitor.response_time_high[0].monitor_thresholds[0].critical) >= 1000
    error_message = "the response time threshold is in milliseconds; a value under 1000 suggests it was copied from the seconds-based app-service module"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    cold_start_high_enabled             = true
    resiliency_request_timeouts_enabled = true
    resiliency_ejected_hosts_enabled    = true
    gpu_utilization_high_enabled        = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.cold_start_high) == 1,
      length(datadog_monitor.resiliency_request_timeouts) == 1,
      length(datadog_monitor.resiliency_ejected_hosts) == 1,
      length(datadog_monitor.gpu_utilization_high) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.resiliency_request_timeouts", datadog_monitor.resiliency_request_timeouts[0].query))
    error_message = "resiliency_request_timeouts must query azure.app_containerapps.resiliency_request_timeouts"
  }

  assert {
    condition     = can(regex("azure\\.app_containerapps\\.gpu_utilization_percentage", datadog_monitor.gpu_utilization_high[0].query))
    error_message = "gpu_utilization_high must query azure.app_containerapps.gpu_utilization_percentage"
  }

  assert {
    condition     = tonumber(datadog_monitor.resiliency_ejected_hosts[0].monitor_thresholds[0].critical) == 0
    error_message = "resiliency_ejected_hosts must default to 0 so any ejected host alerts"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    restart_count_high_enabled = false
    replicas_low_enabled       = false
    cpu_high_enabled           = false
    memory_high_enabled        = false
    response_time_high_enabled = false
    http_5xx_rate_enabled      = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.restart_count_high) == 0,
      length(datadog_monitor.replicas_low) == 0,
      length(datadog_monitor.cpu_high) == 0,
      length(datadog_monitor.memory_high) == 0,
      length(datadog_monitor.response_time_high) == 0,
      length(datadog_monitor.http_5xx_rate) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    cpu_high_threshold_critical           = 70
    cpu_high_threshold_warning            = 55
    restart_count_high_threshold_critical = 3
    http_5xx_rate_threshold_critical      = 2
  }

  assert {
    condition     = can(regex("> 70", datadog_monitor.cpu_high[0].query))
    error_message = "the query comparison must use the critical threshold"
  }

  assert {
    condition     = tonumber(datadog_monitor.cpu_high[0].monitor_thresholds[0].warning) == 55
    error_message = "the warning threshold must reach the monitor"
  }

  assert {
    condition     = can(regex("> 3", datadog_monitor.restart_count_high[0].query))
    error_message = "the restart_count critical threshold must reach its query"
  }

  assert {
    condition     = can(regex("\\* 100 > 2", datadog_monitor.http_5xx_rate[0].query))
    error_message = "the rate monitor must apply its critical threshold after the percentage conversion"
  }
}

run "tags_compose_base_common_and_additional" {
  command = plan

  variables {
    additional_tags = ["extra:tag"]
    env             = "prod"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "resource:container-apps")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
