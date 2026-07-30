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
      length(datadog_monitor.cpu_percentage) == 1,
      length(datadog_monitor.memory_percentage) == 1,
      length(datadog_monitor.http_queue_length) == 1,
    ])
    error_message = "cpu, memory and http queue monitors should be enabled by default"
  }

  assert {
    condition     = length(datadog_monitor.disk_queue_length) == 0
    error_message = "disk_queue_length should be disabled by default"
  }
}

run "queries_target_the_azure_web_serverfarms_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.web_serverfarms\\.cpu_percentage", datadog_monitor.cpu_percentage[0].query))
    error_message = "cpu_percentage must query azure.web_serverfarms.cpu_percentage"
  }

  assert {
    condition     = can(regex("azure\\.web_serverfarms\\.memory_percentage", datadog_monitor.memory_percentage[0].query))
    error_message = "memory_percentage must query azure.web_serverfarms.memory_percentage"
  }

  assert {
    condition     = can(regex("azure\\.web_serverfarms\\.http_queue_length", datadog_monitor.http_queue_length[0].query))
    error_message = "http_queue_length must query azure.web_serverfarms.http_queue_length"
  }

  # Per-site metrics live in a different namespace and belong to the sibling
  # azure/app-service module.
  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_percentage[0].query,
        datadog_monitor.memory_percentage[0].query,
        datadog_monitor.http_queue_length[0].query,
      ] : !can(regex("azure\\.app_services\\.", q))
    ])
    error_message = "per-site metrics belong in azure/app-service, not here"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_percentage[0].query,
        datadog_monitor.memory_percentage[0].query,
        datadog_monitor.http_queue_length[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_percentage[0].query,
        datadog_monitor.memory_percentage[0].query,
        datadog_monitor.http_queue_length[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

run "optional_monitor_can_be_enabled" {
  command = plan

  variables {
    disk_queue_length_enabled = true
  }

  assert {
    condition     = length(datadog_monitor.disk_queue_length) == 1
    error_message = "disk_queue_length_enabled = true must create the monitor"
  }

  assert {
    condition     = can(regex("azure\\.web_serverfarms\\.disk_queue_length", datadog_monitor.disk_queue_length[0].query))
    error_message = "disk_queue_length must query azure.web_serverfarms.disk_queue_length"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    cpu_percentage_enabled    = false
    memory_percentage_enabled = false
    http_queue_length_enabled = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.cpu_percentage) == 0,
      length(datadog_monitor.memory_percentage) == 0,
      length(datadog_monitor.http_queue_length) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    cpu_percentage_threshold_critical = 85
    cpu_percentage_threshold_warning  = 70
  }

  assert {
    condition     = tonumber(datadog_monitor.cpu_percentage[0].monitor_thresholds[0].critical) == 85
    error_message = "cpu_percentage critical threshold must come from the variable"
  }

  assert {
    condition     = can(regex("> 85", datadog_monitor.cpu_percentage[0].query))
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
    condition     = contains(datadog_monitor.cpu_percentage[0].tags, "resource:app-service-plan")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_percentage[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_percentage[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
