# Identity Sub-Module Configuration for Azure Infrastructure

## Introduction

This README provides an overview of the Identity sub-module within the Terraform configuration. It manages resources related to identity services in Azure, focusing on security and monitoring, along with networking components.

## Module Description

### `identity.tf`

Defines resources crucial for managing identity-related configurations in Azure, including security contacts, diagnostic settings, and networking components.

#### Resources and Modules

| Name | Description |
|---|---|
| `azurerm_security_center_contact.defender_default_contact` | Configures Defender for Cloud alerts to a designated security contact email. |
| `time_sleep.wait_30_seconds` | Delays subsequent operations by 30 seconds to manage dependencies. |
| `azurerm_monitor_diagnostic_setting.subscription_activity_logs_diagnostic_settings` | Manages diagnostic settings for Azure subscription activity logs. |
| `module.resource_group_identity` | Creates a resource group specifically for Identity services. |
| `module.resource_group_alert_rules` | Manages a resource group dedicated to alert rules. |
| `module.virtual_network_identity` | Deploys a virtual network tailored for Identity services. |
| `module.virtual_network_identity_diagnostic_settings` | Applies diagnostic settings to the virtual network. |
| `module.resource_group_key_vault` | Creates a resource group for Key Vault resources. |
| `module.kv_subnet` | Configures a subnet within the virtual network for Key Vault services. |
| `azurerm_private_endpoint.kv_sta_pe` | Establishes a private endpoint for Key Vault within the subnet. |
| `module.key_vault` | Sets up an Azure Key Vault in its dedicated resource group. |
| `module.kvid_subnet_network_security_group` | Applies network security group settings to the Key Vault subnet. |
| `module.kvid_subnet_nsg_diagnostic_settings` | Configures diagnostic settings for the Key Vault subnet's NSG. |
| `azurerm_subnet_network_security_group_association.kvid_network_security_group_association` | Associates the Key Vault subnet with its network security group. |
| `module.addc_subnet` | Configures a subnet for Active Directory Domain Controllers. |
| `module.addc_subnet_network_security_group` | Applies NSG settings to the AD DC subnet. |
| `module.addc_subnet_nsg_diagnostic_settings` | Sets diagnostic settings for the AD DC subnet's NSG. |
| `azurerm_subnet_network_security_group_association.addc_network_security_group_association` | Associates the AD DC subnet with its NSG. |
| `module.infoblox_subnet` | Creates a subnet for Infoblox services. |
| `module.infoblox_subnet_network_security_group` | Applies NSG settings to the Infoblox subnet. |
| `module.infoblox_subnet_nsg_diagnostic_settings` | Sets diagnostic settings for the Infoblox subnet's NSG. |
| `azurerm_subnet_network_security_group_association.infoblox_network_security_group_association` | Associates the Infoblox subnet with its NSG. |
| `azurerm_private_dns_resolver.dns_resolver` | Deploys a DNS resolver within the virtual network. |
| `module.pr_subnet_inbound` | Configures an inbound subnet for the DNS resolver. |
| `module.pr_subnet_outbound` | Configures an outbound subnet for the DNS resolver. |
| `azurerm_private_dns_resolver_inbound_endpoint.dnspr_pe_in` | Establishes an inbound endpoint for the DNS resolver. |
| `azurerm_private_dns_resolver_outbound_endpoint.dnspr_pe_out` | Establishes an outbound endpoint for the DNS resolver. |
| `azurerm_monitor_action_group.identity_action_group` | Creates an action group for identity-related alerts. |
| `module.identity_activity_log_alert` | Configures an activity log alert for identity services. |

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
| `application_names` | Maps logical names to resources for consistent naming conventions. |
| `diagnostic_settings` | Defines common settings for managing diagnostics across resources. |
| `network_security_groups` | Lists IDs of network security groups used in flow log settings. |

### `outputs.tf`

Provides output variables that can be used by other Terraform modules or configurations.

#### Outputs

| Name | Description |
|---|---|
| `virtual_network_identity_id` | ID of the Azure Virtual Network created for Identity services. |
| `kv_subnet_id` | ID of the subnet dedicated to Key Vault services. |
| `addc_subnet_id` | ID of the subnet used for Active Directory Domain Controllers. |
| `infoblox_subnet_id` | ID of the subnet allocated for Infoblox services. |
| `pr_subnet_inbound_id` | ID of the inbound subnet for the DNS resolver. |
| `pr_subnet_outbound_id` | ID of the outbound subnet for the DNS resolver. |
| `identity_dns_zone_id` | ID of the DNS zone used for Key Vault services. |

### `provider.tf`

Configures the required providers for the Identity sub-module.

#### Providers

| Name | Description |
|---|---|
| `azurerm` | Configures the Azure RM provider to manage Azure resources. |

### `variables.tf`

Defines input variables for the Identity module.

#### Variables

| Variable Name | Description |
|---|---|
| `application_name` | Specifies the application or service name used for resource naming. |
| `subscription_type` | Identifies the subscription type for resource tagging and management. |
| `environment` | Specifies the deployment environment such as dev, test, or prod. |
| `location` | Azure region where resources will be deployed. |
| `tags` | Tags applied to all resources created by this module. |
| Extensive list of network settings, NSG rules, and log analytics configurations. |

## Conclusion

The Identity sub-module is essential for setting up identity management and security infrastructure within Azure. It ensures the security and proper management of identity-related resources, leveraging Azure's best practices.
