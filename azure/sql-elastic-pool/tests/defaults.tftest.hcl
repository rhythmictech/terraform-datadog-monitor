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
      length(datadog_monitor.cpu_high) == 1,
      length(datadog_monitor.storage_high) == 1,
      length(datadog_monitor.workers_high) == 1,
      length(datadog_monitor.sessions_high) == 1,
    ])
    error_message = "the four purchasing-model-independent monitors should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.log_write_high) == 0,
      length(datadog_monitor.data_io_high) == 0,
      length(datadog_monitor.edtu_consumption_high) == 0,
    ])
    error_message = "log_write, data_io and the DTU-model-only eDTU monitor should be disabled by default"
  }
}

run "queries_target_the_azure_elastic_pool_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.sql_servers_elasticpools\\.cpu_percent", datadog_monitor.cpu_high[0].query))
    error_message = "cpu_high must query azure.sql_servers_elasticpools.cpu_percent"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_elasticpools\\.storage_percent", datadog_monitor.storage_high[0].query))
    error_message = "storage_high must query azure.sql_servers_elasticpools.storage_percent"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_elasticpools\\.workers_percent", datadog_monitor.workers_high[0].query))
    error_message = "workers_high must query azure.sql_servers_elasticpools.workers_percent"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_elasticpools\\.sessions_percent", datadog_monitor.sessions_high[0].query))
    error_message = "sessions_high must query azure.sql_servers_elasticpools.sessions_percent"
  }
}

# The database module shares four metric leaf names with this one and differs
# only in the namespace segment, so cross-wiring would be invisible without this.
run "never_queries_the_database_namespace" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.storage_high[0].query,
        datadog_monitor.workers_high[0].query,
        datadog_monitor.sessions_high[0].query,
      ] : !can(regex("sql_servers_databases", q))
    ])
    error_message = "this module must never query the per-database namespace"
  }
}

run "dtu_metrics_absent_from_enabled_monitors" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.storage_high[0].query,
        datadog_monitor.workers_high[0].query,
        datadog_monitor.sessions_high[0].query,
      ] : !can(regex("dtu", q))
    ])
    error_message = "no monitor enabled by default may depend on a DTU-model metric"
  }
}

run "queries_group_by_azure_identity_tags" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.storage_high[0].query,
        datadog_monitor.workers_high[0].query,
        datadog_monitor.sessions_high[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.storage_high[0].query,
        datadog_monitor.workers_high[0].query,
        datadog_monitor.sessions_high[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    log_write_high_enabled        = true
    data_io_high_enabled          = true
    edtu_consumption_high_enabled = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.log_write_high) == 1,
      length(datadog_monitor.data_io_high) == 1,
      length(datadog_monitor.edtu_consumption_high) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_elasticpools\\.physical_data_read_percent", datadog_monitor.data_io_high[0].query))
    error_message = "data_io_high must query physical_data_read_percent, not a data_io_percent metric that does not exist"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_elasticpools\\.dtu_consumption_percent", datadog_monitor.edtu_consumption_high[0].query))
    error_message = "edtu_consumption_high must query dtu_consumption_percent in the elastic pool namespace"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    cpu_high_enabled      = false
    storage_high_enabled  = false
    workers_high_enabled  = false
    sessions_high_enabled = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.cpu_high) == 0,
      length(datadog_monitor.storage_high) == 0,
      length(datadog_monitor.workers_high) == 0,
      length(datadog_monitor.sessions_high) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    cpu_high_threshold_critical     = 70
    cpu_high_threshold_warning      = 55
    storage_high_threshold_critical = 95
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
    condition     = tonumber(datadog_monitor.storage_high[0].monitor_thresholds[0].critical) == 95
    error_message = "the critical threshold must reach the monitor"
  }
}

run "tags_compose_base_common_and_additional" {
  command = plan

  variables {
    additional_tags = ["extra:tag"]
    env             = "prod"
  }

  assert {
    condition     = contains(datadog_monitor.cpu_high[0].tags, "resource:sql-elastic-pool")
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
