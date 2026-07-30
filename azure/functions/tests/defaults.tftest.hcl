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
      length(datadog_monitor.http_5xx_rate) == 1,
      length(datadog_monitor.response_time) == 1,
    ])
    error_message = "http_5xx_rate and response_time should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.execution_stall) == 0,
      length(datadog_monitor.memory_working_set) == 0,
      length(datadog_monitor.health_check_status) == 0,
    ])
    error_message = "stall, memory and health check monitors should be disabled by default"
  }
}

# azure.functions.* is its own namespace, not a subset of azure.app_services.*.
run "queries_target_the_azure_functions_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.functions\\.http5xx", datadog_monitor.http_5xx_rate[0].query))
    error_message = "http_5xx_rate must query azure.functions.http5xx"
  }

  assert {
    condition     = can(regex("azure\\.functions\\.requests", datadog_monitor.http_5xx_rate[0].query))
    error_message = "http_5xx_rate must divide by azure.functions.requests"
  }

  assert {
    condition     = can(regex("azure\\.functions\\.average_response_time", datadog_monitor.response_time[0].query))
    error_message = "response_time must query azure.functions.average_response_time"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.http_5xx_rate[0].query,
        datadog_monitor.response_time[0].query,
      ] : !can(regex("azure\\.app_services\\.", q))
    ])
    error_message = "Function App metrics must not be read from the app_services namespace"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.http_5xx_rate[0].query,
        datadog_monitor.response_time[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.http_5xx_rate[0].query,
        datadog_monitor.response_time[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    execution_stall_enabled     = true
    memory_working_set_enabled  = true
    health_check_status_enabled = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.execution_stall) == 1,
      length(datadog_monitor.memory_working_set) == 1,
      length(datadog_monitor.health_check_status) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.functions\\.function_execution_count", datadog_monitor.execution_stall[0].query))
    error_message = "execution_stall must query azure.functions.function_execution_count"
  }

  # A stall is "fewer than one execution", so the comparison must be below-threshold.
  assert {
    condition     = can(regex("< 1", datadog_monitor.execution_stall[0].query))
    error_message = "execution_stall must alert when executions drop below 1"
  }

  assert {
    condition     = can(regex("azure\\.functions\\.average_memory_working_set", datadog_monitor.memory_working_set[0].query))
    error_message = "memory_working_set must query azure.functions.average_memory_working_set"
  }

  assert {
    condition     = can(regex("azure\\.functions\\.health_check_status", datadog_monitor.health_check_status[0].query))
    error_message = "health_check_status must query azure.functions.health_check_status"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    http_5xx_rate_enabled = false
    response_time_enabled = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.http_5xx_rate) == 0,
      length(datadog_monitor.response_time) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    response_time_threshold_critical = 8
    response_time_threshold_warning  = 4
  }

  assert {
    condition     = tonumber(datadog_monitor.response_time[0].monitor_thresholds[0].critical) == 8
    error_message = "response_time critical threshold must come from the variable"
  }

  assert {
    condition     = can(regex("> 8", datadog_monitor.response_time[0].query))
    error_message = "the query comparison must use the critical threshold"
  }
}

run "tags_compose_base_common_and_additional" {
  command = plan

  variables {
    additional_tags = ["extra:tag"]
    env             = "prod"
  }

  assert {
    condition     = contains(datadog_monitor.response_time[0].tags, "resource:functions")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.response_time[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.response_time[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
