# Infrastructure Standards Enforcement Guide

This document consolidates AWS Tagging Standards and Infrastructure as Code (IaC) Standards for automated enforcement by AI agents and CI/CD systems.

## AWS Tagging Standards Enforcement

### Required Tags (ENFORCE - BLOCK ON FAILURE)

These tags are mandatory for all resources and must be validated:

| Tag | Validation Pattern | Error Message | Applies To |
|-----|-------------------|---------------|------------|
| `env` | `^[A-Za-z0-9\-_]+$` | "env tag is required. Valid formats: dev, prod, staging, ops" | ALL resources |
| `service` | `^[A-Za-z0-9\-_]+$` | "service tag is required. Format: alphanumeric with hyphens/underscores only" | ALL resources |

### Required When Code Managed (ENFORCE - CONDITIONAL)

These tags are required when resources are managed by IaC:

| Tag | Validation Pattern | Error Message | Condition |
|-----|-------------------|---------------|-----------|
| `code_managed_by` | `^(terraform\|cloudformation\|serverless\|ansible\|cdk)$` | "code_managed_by must be one of: terraform, cloudformation, serverless, ansible, cdk" | When resource is IaC managed |
| `code_managed_at` | `^[a-zA-Z0-9\-_/]+$` | "code_managed_at must specify repository location (e.g., org/aws-infra)" | When resource is IaC managed |

### Required for Ansible-Managed EC2 (ENFORCE - CONDITIONAL)

| Tag | Validation Pattern | Error Message | Condition |
|-----|-------------------|---------------|-----------|
| `profile` | `^[A-Za-z0-9\-_]+$` | "profile tag is required for Ansible-managed EC2 instances" | EC2 instances with Ansible management |

### Recommended Tags (WARN - DO NOT BLOCK)

These tags should be present but won't block deployment:

| Tag | Validation Pattern | Warning Message |
|-----|-------------------|-----------------|
| `version` | `^v[0-9.]+(\-rc[0-9]+)?$` | "version tag recommended. Format: v1.2.3 or v1.2.3-rc1" |
| `datadog_managed` | `^(true\|false\|critical)$` | "datadog_managed tag recommended for monitoring setup" |
| `rhythmic_managed` | `^(true\|false)$` | "rhythmic_managed tag recommended for service coverage tracking" |

### Optional Tags (INFO - NO VALIDATION)

These tags are optional and provide additional metadata:

- `component` - Component identifier (alphanumeric with hyphens/underscores)
- `app` - Application identifier for grouping services
- `cost_center` - Accounting cost center (must align to customer requirements)
- `schedule` - External scheduling tag (must align to scheduler values)
- `backup_policy` - Backup policy identifier
- `dlm_policy` - Data Lifecycle Management policy identifier

### Bill Tags Identification

Tags marked as "Bill Tags" for cost allocation:

- `env` (Y)
- `service` (Y)
- `cost_center` (Y)

## Infrastructure as Code Standards Enforcement

### Tooling Requirements (ENFORCE)

#### Primary Tool Standards

```yaml
terraform_requirements:
  version_pinning: REQUIRED
  validation_pattern: "^[0-9]+\.[0-9]+(\.[0-9]+)?$"
  error_message: "Terraform version must be pinned in .terraform-version or terraform block"
  
provider_versions:
  aws_provider: REQUIRED
  validation_pattern: "^~> [0-9]+\.[0-9]+$"
  error_message: "AWS provider version must be pinned to at least minor version"
```

#### Repository Structure Validation

```yaml
repository_naming:
  pattern: "^aws-[a-zA-Z0-9\-]+-[a-zA-Z0-9\-]+$"
  error_message: "Repository must follow pattern: aws-[client]-[purpose]"

required_files:
  - ".terraform-version"
  - "README.md"
  - ".gitignore"
  - "main.tf"
  - "variables.tf"
  - "outputs.tf"
```

### Code Quality Standards (ENFORCE)

#### Terraform Formatting

```yaml
terraform_fmt:
  enforce: true
  command: "terraform fmt -check -recursive"
  error_message: "Code must be formatted with 'terraform fmt'"

terraform_validate:
  enforce: true
  command: "terraform validate"
  error_message: "Terraform configuration must pass validation"
```

#### Security Scanning

```yaml
security_tools:
  checkov:
    enforce: true
    severity_threshold: "HIGH"
    error_message: "High severity security issues must be resolved"
  
  tflint:
    enforce: true
    config_required: true
    error_message: "TFLint issues must be resolved"

  trivy:
    enforce: true
    severity_threshold: "HIGH"
    error_message: "High severity vulnerabilities must be resolved"
```

### State Management Standards (ENFORCE)

#### Backend Configuration

```yaml
terraform_backend:
  type: "s3"
  required_settings:
    bucket: REQUIRED
    key: REQUIRED
    region: REQUIRED
    encrypt: true
    dynamodb_table: REQUIRED
  
  validation:
    bucket_versioning: REQUIRED
    bucket_encryption: REQUIRED
    error_message: "S3 backend must have versioning and encryption enabled"
```

#### State Organization

```yaml
state_file_rules:
  max_resources_per_state: 50
  warning_threshold: 30
  separate_states_required:
    - "Critical infrastructure (networking, security)"
    - "Different environments (prod/staging/dev)"
    - "Independent workloads"
```

### GitOps Workflow Standards (ENFORCE)

#### Branch Protection

```yaml
branch_protection:
  master_branch:
    required_reviews: 1
    dismiss_stale_reviews: true
    require_code_owner_reviews: false
    required_status_checks:
      - "terraform-plan"
      - "terraform-validate"
      - "security-scan"
    restrict_pushes: true
```

#### Pull Request Requirements

```yaml
pr_requirements:
  terraform_plan: REQUIRED
  plan_in_description: REQUIRED
  validation_passed: REQUIRED
  security_scan_passed: REQUIRED
  
  template_sections:
    - "## Changes"
    - "## Business Justification"
    - "## Terraform Plan Output"
    - "## Testing Performed"
```

### Documentation Standards (WARN)

#### README Requirements

```yaml
readme_sections:
  required:
    - "Purpose and scope"
    - "Prerequisites"
    - "Usage instructions"
    - "Variable documentation"
  
  validation:
    min_length: 500
    terraform_docs: REQUIRED
    warning_message: "README should include all required sections"
```

#### Module Documentation

```yaml
module_documentation:
  terraform_docs: REQUIRED
  variable_descriptions: REQUIRED
  output_descriptions: REQUIRED
  example_usage: REQUIRED
```

### Resource Naming Standards (ENFORCE)

#### Naming Convention

```yaml
resource_naming:
  pattern: "^[client]-[env]-[service]-[resource]-[instance]$"
  validation_pattern: "^[a-zA-Z0-9\-]+-[a-zA-Z0-9\-]+-[a-zA-Z0-9\-]+-[a-zA-Z0-9\-]+-[a-zA-Z0-9\-]+$"
  error_message: "Resources must follow naming pattern: [client]-[env]-[service]-[resource]-[instance]"

naming_exceptions:
  - "IAM roles and policies (AWS character restrictions)"
  - "S3 buckets (global uniqueness requirements)"
  - "Lambda functions (length restrictions)"
```

## AI Agent Implementation Rules

### Blocking vs Non-Blocking Validations

#### BLOCK DEPLOYMENT (Return Error Code)
- Missing required tags (`env`, `service`)
- Missing conditional required tags when applicable
- Terraform validation failures
- High severity security issues
- Unpinned Terraform versions
- Missing state backend configuration
- Branch protection violations
- Failed security scans

#### WARN ONLY (Log Warning, Continue)
- Missing recommended tags
- README documentation issues
- Missing optional documentation
- Style guide violations
- Medium/Low severity security findings

#### INFO ONLY (Log Information)
- Missing optional tags
- Code optimization suggestions
- Best practice recommendations

### Validation Order

1. **Repository Structure** - Validate naming and required files
2. **Terraform Syntax** - Run terraform validate, fmt check
3. **Security Scanning** - Run checkov, tflint, trivy
4. **Tag Validation** - Check required and recommended tags
5. **State Management** - Validate backend configuration
6. **Documentation** - Check README and module docs
7. **Naming Conventions** - Validate resource naming patterns

### Error Reporting Format

```json
{
  "validation_result": "FAILED|PASSED|WARNING",
  "blocking_errors": [
    {
      "category": "TAGGING|SECURITY|SYNTAX|NAMING",
      "severity": "HIGH|MEDIUM|LOW",
      "message": "Detailed error message",
      "resource": "resource_name",
      "fix_suggestion": "How to resolve this issue"
    }
  ],
  "warnings": [],
  "info": []
}
```

### Exception Handling

#### Tag Requirement Exceptions
- Legacy resources (created before standards adoption)
- Third-party managed resources
- AWS managed resources

#### Process for Exceptions
1. Document exception in pull request
2. Add waiver comment in code
3. Track exceptions for future remediation

### Continuous Monitoring

#### Drift Detection
- Monitor for manual changes outside IaC
- Alert on untagged resources
- Track compliance metrics
- Generate compliance reports

#### Metrics to Track
- Tag compliance percentage
- Security scan failure rate
- Documentation coverage
- Standard adoption rate
- Exception requests and resolution

This enforcement guide ensures consistent application of infrastructure standards while providing clear guidance for automated validation and manual review processes.