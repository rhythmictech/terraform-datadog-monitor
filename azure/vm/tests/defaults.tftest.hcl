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
      length(datadog_monitor.availability) == 1,
      length(datadog_monitor.cpu_high) == 1,
      length(datadog_monitor.memory_low) == 1,
      length(datadog_monitor.os_disk_iops_saturation) == 1,
      length(datadog_monitor.data_disk_iops_saturation) == 1,
    ])
    error_message = "the five platform monitors should be enabled by default"
  }

  assert {
    condition     = length(datadog_monitor.cpu_credits_low) == 0
    error_message = "cpu_credits_low should be disabled by default (B-series burstable VMs only)"
  }
}

run "queries_target_the_azure_vm_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.vm\\.vm_availability_metric_preview", datadog_monitor.availability[0].query))
    error_message = "availability must query azure.vm.vm_availability_metric_preview"
  }

  assert {
    condition     = can(regex("azure\\.vm\\.percentage_cpu", datadog_monitor.cpu_high[0].query))
    error_message = "cpu_high must query azure.vm.percentage_cpu"
  }

  assert {
    condition     = can(regex("azure\\.vm\\.available_memory_percentage", datadog_monitor.memory_low[0].query))
    error_message = "memory_low must query azure.vm.available_memory_percentage"
  }

  assert {
    condition     = can(regex("azure\\.vm\\.os_disk_iops_consumed_percentage", datadog_monitor.os_disk_iops_saturation[0].query))
    error_message = "os_disk_iops_saturation must query azure.vm.os_disk_iops_consumed_percentage"
  }

  assert {
    condition     = can(regex("azure\\.vm\\.data_disk_iops_consumed_percentage", datadog_monitor.data_disk_iops_saturation[0].query))
    error_message = "data_disk_iops_saturation must query azure.vm.data_disk_iops_consumed_percentage"
  }

  # azure.vm.status was deprecated and disabled for existing Datadog orgs on
  # 2023-06-01; nothing here may fall back to it.
  assert {
    condition     = !can(regex("azure\\.vm\\.status", datadog_monitor.availability[0].query))
    error_message = "azure.vm.status is deprecated and must not be used"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.availability[0].query,
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.memory_low[0].query,
        datadog_monitor.os_disk_iops_saturation[0].query,
        datadog_monitor.data_disk_iops_saturation[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  # `host` keeps platform-metric alerts joinable to the agent-based host/* monitors.
  assert {
    condition     = can(regex("host", datadog_monitor.cpu_high[0].query))
    error_message = "VM queries must group by host so they correlate with host/* monitors"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.availability[0].query,
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.memory_low[0].query,
        datadog_monitor.os_disk_iops_saturation[0].query,
        datadog_monitor.data_disk_iops_saturation[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

run "optional_monitor_can_be_enabled" {
  command = plan

  variables {
    cpu_credits_low_enabled = true
  }

  assert {
    condition     = length(datadog_monitor.cpu_credits_low) == 1
    error_message = "cpu_credits_low_enabled = true must create the monitor"
  }

  assert {
    condition     = can(regex("azure\\.vm\\.cpu_credits_remaining", datadog_monitor.cpu_credits_low[0].query))
    error_message = "cpu_credits_low must query azure.vm.cpu_credits_remaining"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    availability_enabled              = false
    cpu_high_enabled                  = false
    memory_low_enabled                = false
    os_disk_iops_saturation_enabled   = false
    data_disk_iops_saturation_enabled = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.availability) == 0,
      length(datadog_monitor.cpu_high) == 0,
      length(datadog_monitor.memory_low) == 0,
      length(datadog_monitor.os_disk_iops_saturation) == 0,
      length(datadog_monitor.data_disk_iops_saturation) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    cpu_high_threshold_critical = 75
    cpu_high_threshold_warning  = 60
  }

  assert {
    condition     = tonumber(datadog_monitor.cpu_high[0].monitor_thresholds[0].critical) == 75
    error_message = "cpu_high critical threshold must come from the variable"
  }

  assert {
    condition     = tonumber(datadog_monitor.cpu_high[0].monitor_thresholds[0].warning) == 60
    error_message = "cpu_high warning threshold must come from the variable"
  }

  assert {
    condition     = can(regex("> 75", datadog_monitor.cpu_high[0].query))
    error_message = "the query comparison must use the critical threshold"
  }

  # memory_low is a below-threshold monitor: warning must sit above critical.
  assert {
    condition     = tonumber(datadog_monitor.memory_low[0].monitor_thresholds[0].warning) > tonumber(datadog_monitor.memory_low[0].monitor_thresholds[0].critical)
    error_message = "for a < comparison the warning threshold must be greater than critical"
  }
}

run "tags_compose_base_common_and_additional" {
  command = plan

  variables {
    additional_tags = ["extra:tag"]
    env             = "prod"
    service         = "castalia"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "resource:vm")
    error_message = "base_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "extra:tag")
    error_message = "additional_tags must be applied"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "env:prod")
    error_message = "env must become a common tag"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "provisioned-by:terraform")
    error_message = "common.tf must always add provisioned-by:terraform"
  }
}
