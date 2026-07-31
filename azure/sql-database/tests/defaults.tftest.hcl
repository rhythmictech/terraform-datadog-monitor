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
      length(datadog_monitor.deadlocks) == 1,
      length(datadog_monitor.connection_failures) == 1,
      length(datadog_monitor.workers_high) == 1,
      length(datadog_monitor.sessions_high) == 1,
    ])
    error_message = "the six purchasing-model-independent monitors should be enabled by default"
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.log_write_high) == 0,
      length(datadog_monitor.dtu_consumption_high) == 0,
    ])
    error_message = "log_write_high and the DTU-model-only monitor should be disabled by default"
  }
}

run "queries_target_the_azure_sql_database_namespace" {
  command = plan

  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.cpu_percent", datadog_monitor.cpu_high[0].query))
    error_message = "cpu_high must query azure.sql_servers_databases.cpu_percent"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.storage_percent", datadog_monitor.storage_high[0].query))
    error_message = "storage_high must query azure.sql_servers_databases.storage_percent"
  }

  # The metric is `deadlock`, singular. Guard against it drifting to `deadlocks`.
  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.deadlock[^s]", datadog_monitor.deadlocks[0].query))
    error_message = "deadlocks must query azure.sql_servers_databases.deadlock, singular"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.connection_failed", datadog_monitor.connection_failures[0].query))
    error_message = "connection_failures must query azure.sql_servers_databases.connection_failed"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.workers_percent", datadog_monitor.workers_high[0].query))
    error_message = "workers_high must query azure.sql_servers_databases.workers_percent"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.sessions_percent", datadog_monitor.sessions_high[0].query))
    error_message = "sessions_high must query azure.sql_servers_databases.sessions_percent"
  }
}

# The elastic pool module is one namespace away and easy to cross-wire.
run "never_queries_the_elastic_pool_namespace" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.storage_high[0].query,
        datadog_monitor.deadlocks[0].query,
        datadog_monitor.connection_failures[0].query,
        datadog_monitor.workers_high[0].query,
        datadog_monitor.sessions_high[0].query,
      ] : !can(regex("sql_servers_elasticpools", q))
    ])
    error_message = "this module must never query the elastic pool namespace"
  }
}

# The DTU purchasing model is the exception, not the default. A vCore database
# emits nothing for these, so no enabled-by-default monitor may depend on them.
run "dtu_metrics_absent_from_enabled_monitors" {
  command = plan

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.storage_high[0].query,
        datadog_monitor.deadlocks[0].query,
        datadog_monitor.connection_failures[0].query,
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
        datadog_monitor.deadlocks[0].query,
        datadog_monitor.connection_failures[0].query,
      ] : can(regex("subscription_name", q))
    ])
    error_message = "every query must group by subscription_name"
  }

  assert {
    condition = alltrue([
      for q in [
        datadog_monitor.cpu_high[0].query,
        datadog_monitor.storage_high[0].query,
        datadog_monitor.deadlocks[0].query,
        datadog_monitor.connection_failures[0].query,
      ] : !can(regex("aws_account|aws\\.", q))
    ])
    error_message = "no AWS metric prefixes or aws_account grouping permitted under azure/"
  }
}

run "optional_monitors_can_be_enabled" {
  command = plan

  variables {
    log_write_high_enabled       = true
    dtu_consumption_high_enabled = true
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.log_write_high) == 1,
      length(datadog_monitor.dtu_consumption_high) == 1,
    ])
    error_message = "each optional monitor must be creatable via its *_enabled flag"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.log_write_percent", datadog_monitor.log_write_high[0].query))
    error_message = "log_write_high must query azure.sql_servers_databases.log_write_percent"
  }

  assert {
    condition     = can(regex("azure\\.sql_servers_databases\\.dtu_consumption_percent", datadog_monitor.dtu_consumption_high[0].query))
    error_message = "dtu_consumption_high must query azure.sql_servers_databases.dtu_consumption_percent"
  }
}

run "monitors_can_be_disabled" {
  command = plan

  variables {
    cpu_high_enabled            = false
    storage_high_enabled        = false
    deadlocks_enabled           = false
    connection_failures_enabled = false
    workers_high_enabled        = false
    sessions_high_enabled       = false
  }

  assert {
    condition = alltrue([
      length(datadog_monitor.cpu_high) == 0,
      length(datadog_monitor.storage_high) == 0,
      length(datadog_monitor.deadlocks) == 0,
      length(datadog_monitor.connection_failures) == 0,
      length(datadog_monitor.workers_high) == 0,
      length(datadog_monitor.sessions_high) == 0,
    ])
    error_message = "every *_enabled = false must remove its monitor"
  }
}

run "thresholds_plumb_through" {
  command = plan

  variables {
    deadlocks_threshold_critical = 0
    cpu_high_threshold_critical  = 75
    cpu_high_threshold_warning   = 60
  }

  assert {
    condition     = tonumber(datadog_monitor.deadlocks[0].monitor_thresholds[0].critical) == 0
    error_message = "a zero-tolerance deadlock override must reach the monitor"
  }

  assert {
    condition     = can(regex("> 75", datadog_monitor.cpu_high[0].query))
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
    condition     = contains(datadog_monitor.cpu_high[0].tags, "resource:sql-database")
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
