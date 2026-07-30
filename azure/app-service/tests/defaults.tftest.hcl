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
      length(datadog_monitor.http_4xx_rate) == 0,
      length(datadog_monitor.health_check_status) == 0,
      length(datadog_monitor.file_system_usage) == 0,
    ])
    error_message = "4xx, health check and filesystem monitors should be disabled by default"
  }
}

run "queries_target_the_azure_app_services_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.app_services\\.http5xx", datadog_monitor.http_5xx_rate[0].query))
    error_message = "http_5xx_rate must query azure.app_services.http5xx"
  }

  # The rate is 5xx over total requests, so both metrics must appear.
  assert {
    condition     = can(regex("azure\\.app_services\\.requests", datadog_monitor.http_5xx_rate[0].query))
    error_message = "http_5xx_rate must divide by azure.app_services.requests"
  }

  assert {
    condition     = can(regex("azure\\.app_services\\.average_response_time", datadog_monitor.response_time[0].query))
    error_message = "response_time must query azure.app_services.average_response_time"
  }

  # App Service Plan metrics live in a different namespace and belong to the
  # sibling azure/app-service-plan module.
  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.http_5xx_rate[0].query,
        datadog_monitor.response_time[0].query,
      ] : !can(regex("azure\\.web_serverfarms\\.", q))
    ])
    error_message = "plan metrics belong in azure/app-service-plan, not here"
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
    http_4xx_rate_enabled       = true
    health_check_status_enabled = true
    file_system_usage_enabled   = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.http_4xx_rate) == 1,
      length(datadog_monitor.health_check_status) == 1,
      length(datadog_monitor.file_system_usage) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.app_services\\.http4xx", datadog_monitor.http_4xx_rate[0].query))
    error_message = "http_4xx_rate must query azure.app_services.http4xx"
  }

  assert {
    condition     = can(regex("azure\\.app_services\\.health_check_status", datadog_monitor.health_check_status[0].query))
    error_message = "health_check_status must query azure.app_services.health_check_status"
  }

  assert {
    condition     = can(regex("azure\\.app_services\\.file_system_usage", datadog_monitor.file_system_usage[0].query))
    error_message = "file_system_usage must query azure.app_services.file_system_usage"
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
    http_5xx_rate_threshold_critical = 2
    http_5xx_rate_threshold_warning  = 1
  }

  assert {
    condition     = tonumber(datadog_monitor.http_5xx_rate[0].monitor_thresholds[0].critical) == 2
    error_message = "http_5xx_rate critical threshold must come from the variable"
  }

  assert {
    condition     = can(regex("> 2", datadog_monitor.http_5xx_rate[0].query))
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
    condition     = contains(datadog_monitor.response_time[0].tags, "resource:app-service")
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
