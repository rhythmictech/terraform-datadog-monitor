# terraform-datadog-monitor

A collection of semi-opinionated Datadog monitors for a variety of use cases.

[![tflint](https://github.com/rhythmictech/terraform-datadog-monitor/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-datadog-monitor/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-datadog-monitor/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-datadog-monitor/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-datadog-monitor/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-datadog-monitor/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-datadog-monitor/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-datadog-monitor/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-datadog-monitor/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-datadog-monitor/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Requirements
* DataDog provider
* DataDog API key

## Example
```hcl
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

module "monitor" {
  source = "rhythmictech/monitors/datadog/aws/ec2"

}
```

## About

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
