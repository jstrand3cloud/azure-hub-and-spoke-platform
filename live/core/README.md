# Terraform Configuration for Azure Infrastructure Management

## Introduction

This document details the Terraform configuration used for managing Azure resources across multiple environments and subscriptions. It includes comprehensive definitions for various components through organized `.tf` files.

## File Descriptions

### `main.tf`

This file contains the definitions of resources and modules used to manage Azure subscriptions and resources.

#### Modules/Resources

| Module/Resource Name                   | Description                                                       |
|----------------------------------------|-------------------------------------------------------------------|
| `management_subscription`              | Manages resources for the Management environment.                 |
| `identity_subscription`                | Sets up Identity-related resources and configurations.            |
| `connectivity_subscription`            | Configures the Connectivity hub and associated network settings.  |
| `alz-tbd-dev-01_subscription`         | Manages resources for the tbd Development 01 environment.        |
| `azurerm_virtual_hub_connection`       | Connects various environments to the managed virtual hub.         |

### `locals.tf`

Defines local variables to simplify management and reduce code duplication.

#### Local Variables

| Variable Name          | Description                                      |
|------------------------|--------------------------------------------------|
| `subscription_types`   | Maps descriptive names to subscription types.    |
| `environment`          | Maps specific environment settings per module.   |

### `variables.tf`

Defines input variables required by the Terraform configuration.

#### Variables

| Variable Name                          | Description                                                        |
|----------------------------------------|--------------------------------------------------------------------|
| `connectivity_subscription_id`         | Subscription ID for the Connectivity context.                      |
| `identity_subscription_id`             | Subscription ID for Identity operations.                           |
| `management_subscription_id`           | Subscription ID for Management operations.                         |
| `alz-tbd-dev-01_subscription_id`      | Subscription ID for tbd Development 01 operations.                |
| `tags`                                 | Tags to be applied to all resources.                               |
| `location`                             | Azure region for resource deployment.                              |
| Additional variables for network configurations, resource naming, tagging and security rules.

### `provider.tf`

Sets up and configures the required providers for different Azure subscriptions.

#### Provider Aliases

| Provider Alias                 | Description                                               |
|--------------------------------|-----------------------------------------------------------|
| `connectivity-sub`             | Provider for the Connectivity subscription context.       |
| `identity-sub`                 | Provider for the Identity subscription context.           |
| `management-sub`               | Provider for the Management subscription context.         |
| `alz-tbd-dev-01-sub`          | Provider for the tbd Development 01 subscription context. |

## Deployment Instructions

This Terraform setup is intended to be run through Azure DevOps Pipelines. Ensure the pipeline is configured to use the correct Terraform version and has access to the necessary Azure subscriptions.

1. **Pipeline Setup**: Configure your Azure DevOps pipeline to use this Terraform configuration.
2. **Variable Group**: Ensure a variable group is linked with all required secrets and identifiers used across the Terraform configurations.

### Using `alzcore.tfvars`

The `alzcore.tfvars` file provides a centralized place to manage values for Terraform variables applicable across the entire configuration. It simplifies management by keeping environment-specific values in one location which is used during the pipeline execution.

- **Important**: Update the `alzcore.tfvars` file with relevant values before initiating a pipeline run to ensure all configurations are correctly applied.

## Conclusion

This Terraform setup provides a structured approach to managing complex, multi-environment Azure infrastructures. It leverages modularity and reusability across different Azure subscriptions.
