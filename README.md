# Table of content
- [Table of content](#table-of-content)
- [Futurestack-2022-workshop](#futurestack-2022-workshop)
- [Description](#description)
- [Requirements](#requirements)
- [Setup](#setup)
  - [Configure the Dashboard](#configure-the-dashboard)
    - [Option 1: Variables file](#option-1-variables-file)
    - [Option 2: Environment variables](#option-2-environment-variables)
  - [Initialize Terraform](#initialize-terraform)
- [Validate and create Dashboard](#validate-and-create-dashboard)

# Futurestack-2022-workshop
How to optimize the size your k8s containers to reduce cost and improve performance, using New Relic

# Description
Similar to bare metal machines or VMs being too large for a given workload, a container can also be too large to address the resource requirements appropriately.

If a container is not large enough, the workload can suffer on the other hand, e.g. by being throttled or restarted. 

The goal of this workshop is to understand how to detect such cases, and optimize the resources allocation.

# Requirements
- Terraform [1.0.0](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started#install-terraform) or newer installed
- At least one k8s cluster with [New Relic monitoring](https://docs.newrelic.com/docs/kubernetes-pixie/kubernetes-integration/installation/kubernetes-integration-install-configure/) deployed, using version [1.23.0](https://docs.newrelic.com/docs/release-notes/infrastructure-release-notes/kubernetes-integration-release-notes/kubernetes-integration-1230/) or newer
- Your New Relic account ID to deploy the Dashboard
- Your New Relic region
- A personal New Relic API key

# Setup
## Configure the Dashboard
To configure the Dashboard to your needs, you have two options: Use a variables file or export environment variables.

All variables are explained in the `variables.tf` file.

**The two variables you have to set are `account_id` and `api_key`.** All other variables can be ommitted as they also come with defaults.

### Option 1: Variables file
Copy the `example.tfvars` file and adjust the values to your needs:
``` bash
cp example.tfvars terraform.tfvars
```

### Option 2: Environment variables
Export each of the variables as an environment variable by prefixing them with `TF_VAR_`, e.g. `TF_VAR_account_id` for the variable `account_id`:
``` bash
export TF_VAR_account_id=123456
```

## Initialize Terraform
Terraform needs to download the New Relic provider to be able to perform the required API calls on your behalf:

``` bash
terraform init
```

# Validate and create Dashboard
Perform a dry-run of your configuration change and review the planned changes:

``` bash
terraform plan -out=tfplan
```

If the plan runs without errors and the planned changes are correct, apply the changes:

``` bash
terraform apply tfplan
```
The above two steps can be repeated to apply any change made to the Dashboard, be that changes to the variables (`terraform.tfvars` or exported environment variables), or to the Dashboard itself (`dashboard.tf`).

A successfully executed planfile will print a Dashboard URL at the end of the prompt. The URL will redirect you to your Dashboard that you can now use to analyze your workloads.