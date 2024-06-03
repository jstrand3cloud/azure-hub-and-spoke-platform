# Management Sub-Module Configuration for Azure Infrastructure

## Introduction

This README provides an overview of the Management sub-module within the Terraform configuration. It manages resources related to Azure management operations, focusing on resource groups, managed identities, and diagnostic settings along with extensive configurations for networking and monitoring.

## Module Description

### `management.tf`

Defines resources crucial for managing infrastructure and operational tasks in Azure, including setting up security contacts, managed identities, and comprehensive diagnostic settings for network monitoring.

#### Resources and Modules

| Name | Type | Description |
|---|---|---|
| `azurerm_security_center_contact.defender_default_contact` | Resource | Configures Azure Defender alerts to a designated security contact email. |
| `time_sleep.wait_30_seconds` | Resource | Delays operations by 30 seconds to manage dependencies more effectively. |
| `azurerm_monitor_diagnostic_setting.subscription_activity_logs_diagnostic_settings` | Resource | Manages diagnostic settings for Azure subscription activity logs. |
| `module.resource_group_mgmt` | Module | Creates a resource group specifically for management services. |
| `module.resource_group_alert_rules` | Module | Manages a resource group dedicated to alert rules. |
| `module.virtual_network_mgmt` | Module | Deploys a virtual network tailored for management services. |
| `module.virtual_network_mgmt_diagnostic_settings` | Module | Applies diagnostic settings to the management virtual network. |
| `module.log_analytics_workspace` | Module | Sets up a Log Analytics Workspace for centralized log management. |
| `module.log_analytics_workspace_diagnostic_settings` | Module | Configures diagnostic settings for the Log Analytics Workspace. |
| `azurerm_user_assigned_identity.managed_identity_azpol_defender` | Resource | Establishes a managed identity for Azure Policy Defender compliance. |
| `azurerm_user_assigned_identity.managed_identity_azpol_logging` | Resource | Sets up a managed identity for Azure logging policy compliance. |
| `azurerm_user_assigned_identity.managed_identity_sandbox_cleanup` | Resource | Establishes a managed identity for sandbox environment cleanup tasks. |
| `azurerm_user_assigned_identity.managed_identity_azpol_backup_vault_send_email` | Resource | Configures a managed identity for backup vault email notifications. |
| `module.key_vault` | Module | Sets up an Azure Key Vault in its dedicated resource group. |
| `module.key_vault_diagnostic_settings` | Module | Configures diagnostic settings for Azure Key Vault. |
| `module.virtual_network_mgmt` | Module | Deploys and manages a virtual network for management-related resources. |
| `module.mgmt_eventhub_namespace_diagnostic_settings` | Module | Applies diagnostic settings to the Event Hub namespace used for management events. |
| `module.storage_account_tfstate` | Module | Configures a storage account specifically for Terraform state files. |
| `module.storage_account_nsgflow` | Module | Sets up a storage account used for NSG flow logs. |
| `module.ado_pipeline_agents_subnet` | Module | Configures a subnet within the management virtual network for Azure DevOps pipeline agents. |
| `module.bastion_host` | Module | Deploys an Azure Bastion host for secure RDP and SSH access to virtual machines. |
| `module.public_ip_bastion` | Module | Provides a public IP for the Azure Bastion service. |
| `azurerm_private_dns_zone.blob_storage_dns_zone` | Resource | Manages the private DNS zone for blob storage. |
| `azurerm_private_dns_zone.keyvault_dns_zone` | Resource | Manages the private DNS zone for Key Vault. |
| More detailed rows for each resource and module as found in `management.tf`. |

### `data.tf`

Defines data sources to fetch existing configuration details from Azure.

#### Data Sources

| Name | Description |
|---|---|
| `azurerm_subscription.current` | Retrieves the current Azure subscription details. |

### `locals.tf`

Manages local variables used to simplify naming and configurations within the module.

#### Local Variables

| Variable Name | Description |
|---|---|
| `application_names` | Maps logical names to Azure resources for consistent naming across the module. |
| `diagnostic_settings` | Defines common settings for diagnostics across resources to maintain compliance and monitoring standards. |

### `outputs.tf`

Provides output variables that can be used by other Terraform modules or configurations.

#### Outputs

| Name | Description |
|---|---|
| `virtual_network_mgmt_id` | ID of the Azure Virtual Network created for management services. |
| `log_analytics_workspace_id` | ID of the Log Analytics Workspace used for log management. |
| `key_vault_id` | ID of the Azure Key Vault used for secure storage of secrets. |
| Additional outputs for other resources and configurations as required by the module. |

### `provider.tf`

Configures the required providers for the Management sub-module.

#### Providers

| Name | Description |
|---|---|
| `azurerm` | Configures the Azure RM provider to manage Azure resources effectively. |

### `variables.tf`

Defines input variables for the Management module.

#### Variables

| Variable Name | Description |
|---|---|
| `subscription_type` | Defines the subscription type, used for resource allocation and policy application. |
| `environment` | Specifies the deployment environment (dev, test, prod). |
| `location` | Determines the Azure region where resources will be deployed. |
| `tags` | Provides a standardized set of metadata tags applied to all resources within the module. |
| Additional variables related to network configurations, NSG rules, and Azure policies. |

## Conclusion

The Management sub-module is vital for orchestrating the setup and ongoing management of Azure resources, ensuring operational efficiency and compliance with organizational policies and Azure best practices.
