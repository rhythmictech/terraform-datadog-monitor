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
      length(datadog_monitor.error_rate) == 1,
      length(datadog_monitor.availability_rate) == 1,
      length(datadog_monitor.blocked_calls) == 1,
    ])
    error_message = "the three quota-independent monitors should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.latency) == 0,
      length(datadog_monitor.provisioned_utilization) == 0,
      length(datadog_monitor.model_availability_rate) == 0,
    ])
    error_message = "the deployment-dependent monitors should be disabled by default"
  }
}

run "queries_target_the_azure_cognitiveservices_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.cognitiveservices_accounts\\.total_errors", datadog_monitor.error_rate[0].query))
    error_message = "error_rate must query azure.cognitiveservices_accounts.total_errors"
  }

  assert {
    condition     = can(regex("azure\\.cognitiveservices_accounts\\.total_calls", datadog_monitor.error_rate[0].query))
    error_message = "error_rate must divide by azure.cognitiveservices_accounts.total_calls"
  }

  assert {
    condition     = can(regex("azure\\.cognitiveservices_accounts\\.availability_rate", datadog_monitor.availability_rate[0].query))
    error_message = "availability_rate must query azure.cognitiveservices_accounts.availability_rate"
  }

  assert {
    condition     = can(regex("azure\\.cognitiveservices_accounts\\.blocked_calls", datadog_monitor.blocked_calls[0].query))
    error_message = "blocked_calls must query azure.cognitiveservices_accounts.blocked_calls"
  }
}

# AI Foundry (Azure OpenAI) and Document Intelligence (Form Recognizer) share
# this metric namespace and are told apart only by the `kind` tag, so every
# monitor must group by it or alerts become unattributable.
run "queries_group_by_kind_to_separate_account_types" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.error_rate[0].query,
        datadog_monitor.availability_rate[0].query,
        datadog_monitor.blocked_calls[0].query,
      ] : can(regex("kind", q))
    ])
    error_message = "every query must group by kind to separate OpenAI from Form Recognizer"
  }

  assert {
    condition     = can(regex("\\{\\{kind\\.name\\}\\}", datadog_monitor.error_rate[0].name))
    error_message = "the monitor title must surface kind so the alert names the account type"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.error_rate[0].query,
        datadog_monitor.availability_rate[0].query,
        datadog_monitor.blocked_calls[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.error_rate[0].query,
        datadog_monitor.availability_rate[0].query,
        datadog_monitor.blocked_calls[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

run "any_occurrence_threshold_is_zero" {
  command = plan

  assert {
    condition     = tonumber(datadog_monitor.blocked_calls[0].monitor_thresholds[0].critical) == 0
    error_message = "blocked_calls must default to 0 so any blocked call alerts"
  }

  assert {
    condition     = can(regex("> 0", datadog_monitor.blocked_calls[0].query))
    error_message = "blocked_calls query must compare against 0"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    latency_enabled                 = true
    provisioned_utilization_enabled = true
    model_availability_rate_enabled = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.latency) == 1,
      length(datadog_monitor.provisioned_utilization) == 1,
      length(datadog_monitor.model_availability_rate) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.cognitiveservices_accounts\\.latency", datadog_monitor.latency[0].query))
    error_message = "latency must query azure.cognitiveservices_accounts.latency"
  }

  assert {
    condition     = can(regex("azure\\.cognitiveservices_accounts\\.provisioned_utilization", datadog_monitor.provisioned_utilization[0].query))
    error_message = "provisioned_utilization must query azure.cognitiveservices_accounts.provisioned_utilization"
  }

  assert {
    condition     = can(regex("azure\\.cognitiveservices_accounts\\.model_availability_rate", datadog_monitor.model_availability_rate[0].query))
    error_message = "model_availability_rate must query azure.cognitiveservices_accounts.model_availability_rate"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    error_rate_enabled        = false
    availability_rate_enabled = false
    blocked_calls_enabled     = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.error_rate) == 0,
      length(datadog_monitor.availability_rate) == 0,
      length(datadog_monitor.blocked_calls) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    error_rate_threshold_critical = 3
    error_rate_threshold_warning  = 2
  }

  assert {
    condition     = tonumber(datadog_monitor.error_rate[0].monitor_thresholds[0].critical) == 3
    error_message = "error_rate critical threshold must come from the variable"
  }

  assert {
    condition     = can(regex("> 3", datadog_monitor.error_rate[0].query))
    error_message = "the query comparison must use the critical threshold"
  }

  # availability_rate is a below-threshold monitor: warning must sit above critical.
  assert {
    condition     = tonumber(datadog_monitor.availability_rate[0].monitor_thresholds[0].warning) > tonumber(datadog_monitor.availability_rate[0].monitor_thresholds[0].critical)
    error_message = "for a < comparison the warning threshold must be greater than critical"
  }
}

run "tags_compose_base_common_and_additional" {
  command = plan

  variables {
    additional_tags = ["extra:tag"]
    env             = "prod"
  }

  assert {
    condition     = contains(datadog_monitor.error_rate[0].tags, "resource:cognitive-services")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.error_rate[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.error_rate[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
