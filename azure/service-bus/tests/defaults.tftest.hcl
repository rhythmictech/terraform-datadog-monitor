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
      length(datadog_monitor.dead_lettered_messages) == 1,
      length(datadog_monitor.server_errors) == 1,
      length(datadog_monitor.throttled_requests) == 1,
      length(datadog_monitor.active_messages_backlog) == 1,
    ])
    error_message = "the four SKU-independent monitors should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.user_errors) == 0,
      length(datadog_monitor.cpu) == 0,
      length(datadog_monitor.memory_usage) == 0,
    ])
    error_message = "user_errors and the Premium-only cpu/memory monitors should be disabled by default"
  }
}

run "queries_target_the_azure_servicebus_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.servicebus_namespaces\\.count_of_dead_lettered_messages_in_a_queue_topic", datadog_monitor.dead_lettered_messages[0].query))
    error_message = "dead_lettered_messages must query count_of_dead_lettered_messages_in_a_queue_topic"
  }

  assert {
    condition     = can(regex("azure\\.servicebus_namespaces\\.server_errors", datadog_monitor.server_errors[0].query))
    error_message = "server_errors must query azure.servicebus_namespaces.server_errors"
  }

  assert {
    condition     = can(regex("azure\\.servicebus_namespaces\\.throttled_requests", datadog_monitor.throttled_requests[0].query))
    error_message = "throttled_requests must query azure.servicebus_namespaces.throttled_requests"
  }

  assert {
    condition     = can(regex("azure\\.servicebus_namespaces\\.count_of_active_messages_in_a_queue_topic", datadog_monitor.active_messages_backlog[0].query))
    error_message = "active_messages_backlog must query count_of_active_messages_in_a_queue_topic"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.dead_lettered_messages[0].query,
        datadog_monitor.server_errors[0].query,
        datadog_monitor.throttled_requests[0].query,
        datadog_monitor.active_messages_backlog[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  # entity_name splits namespace-level metrics down to the individual queue or topic.
  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.dead_lettered_messages[0].query,
        datadog_monitor.active_messages_backlog[0].query,
      ] : can(regex("entity_name", q))
    ])
    error_message = "per-entity metrics must group by entity_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.dead_lettered_messages[0].query,
        datadog_monitor.server_errors[0].query,
        datadog_monitor.throttled_requests[0].query,
        datadog_monitor.active_messages_backlog[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

# Count-style monitors compare with `>`, so a threshold of 0 is what makes
# "any occurrence alerts" true. Guard that intent.
run "any_occurrence_thresholds_are_zero" {
  command = plan

  assert {
    condition     = tonumber(datadog_monitor.server_errors[0].monitor_thresholds[0].critical) == 0
    error_message = "server_errors must default to 0 so any server error alerts"
  }

  assert {
    condition     = tonumber(datadog_monitor.dead_lettered_messages[0].monitor_thresholds[0].warning) == 0
    error_message = "dead_lettered_messages must warn at 0 so any dead letter warns"
  }

  assert {
    condition     = can(regex("> 0", datadog_monitor.server_errors[0].query))
    error_message = "server_errors query must compare against 0"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    user_errors_enabled  = true
    cpu_enabled          = true
    memory_usage_enabled = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.user_errors) == 1,
      length(datadog_monitor.cpu) == 1,
      length(datadog_monitor.memory_usage) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.servicebus_namespaces\\.user_errors", datadog_monitor.user_errors[0].query))
    error_message = "user_errors must query azure.servicebus_namespaces.user_errors"
  }

  assert {
    condition     = can(regex("azure\\.servicebus_namespaces\\.cpu", datadog_monitor.cpu[0].query))
    error_message = "cpu must query azure.servicebus_namespaces.cpu"
  }

  assert {
    condition     = can(regex("azure\\.servicebus_namespaces\\.memory_usage", datadog_monitor.memory_usage[0].query))
    error_message = "memory_usage must query azure.servicebus_namespaces.memory_usage"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    dead_lettered_messages_enabled  = false
    server_errors_enabled           = false
    throttled_requests_enabled      = false
    active_messages_backlog_enabled = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.dead_lettered_messages) == 0,
      length(datadog_monitor.server_errors) == 0,
      length(datadog_monitor.throttled_requests) == 0,
      length(datadog_monitor.active_messages_backlog) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    dead_lettered_messages_threshold_critical  = 0
    active_messages_backlog_threshold_critical = 250
    active_messages_backlog_threshold_warning  = 100
  }

  assert {
    condition     = tonumber(datadog_monitor.dead_lettered_messages[0].monitor_thresholds[0].critical) == 0
    error_message = "the documented zero-tolerance override must reach the monitor"
  }

  assert {
    condition     = can(regex("> 250", datadog_monitor.active_messages_backlog[0].query))
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
    condition     = contains(datadog_monitor.server_errors[0].tags, "resource:service-bus")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.server_errors[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.server_errors[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
