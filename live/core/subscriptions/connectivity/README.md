# Connectivity Sub-Module Configuration for Azure Infrastructure

## Introduction

This README provides an overview of the Connectivity sub-module within the Terraform configuration. It is designed to manage Azure Virtual WAN (VWAN) resources, monitoring settings, and security components like Azure Firewall within a structured and scalable framework.

## Module Description

### `connectivity.tf`

Defines resources for security monitoring, logging, resource groups, and network components, specifically focusing on Virtual WAN and Azure Firewall configurations.

#### Resources and Modules

| Name                                  | Description                                                   |
|---------------------------------------|---------------------------------------------------------------|
| `azurerm_security_center_contact`     | Sets up security center contact for Defender for Cloud alerts.|
| `azurerm_monitor_diagnostic_setting`  | Configures diagnostic settings for subscription activity logs.|
| `module.resource_group_vwan`          | Creates a resource group for VWAN components.                 |
| `module.resource_group_alert_rules`   | Creates a resource group for alert rules.                     |
| `azurerm_virtual_wan`                 | Configures the Azure Virtual WAN.                             |
| `azurerm_virtual_hub`                 | Sets up a Virtual Hub within the Virtual WAN.                 |
| `azurerm_firewall`                    | Deploys an Azure Firewall in the specified Virtual Hub.       |
| `azurerm_firewall_policy`             | Defines a firewall policy for the deployed Azure Firewall.    |
| `azurerm_virtual_hub_routing_intent`  | Configures routing intents for the Virtual Hub.               |
| `azurerm_vpn_gateway`                 | Creates a VPN Gateway in the Virtual Hub.                     |
| `azurerm_vpn_site`                    | Sets up a VPN Site for establishing VPN connections.          |
| `azurerm_vpn_gateway_connection`      | Manages connections between the VPN gateway and VPN site.     |
| `azurerm_monitor_action_group`        | Creates an action group for alerts.                           |
| `module.firewall_diagnostic_settings` | Applies diagnostic settings to the firewall.                  |

### `data.tf`

Defines data sources used to fetch existing configuration details from Azure.

#### Data Sources

| Name                      | Description                                         |
|---------------------------|-----------------------------------------------------|
| `azurerm_subscription`    | Retrieves current Azure subscription details.       |

### `locals.tf`

Manages local variables used to simplify naming and configurations within the module.

#### Local Variables

| Name                      | Description                                         |
|---------------------------|-----------------------------------------------------|
| `application_names`       | Maps logical names to resources for naming purposes.|
| `diagnostic_settings`     | Defines settings for managing diagnostics.          |

### `outputs.tf`

Provides output variables that can be used by other Terraform modules or configurations.

#### Outputs

| Name                      | Description                                         |
|---------------------------|-----------------------------------------------------|
| `azurerm_virtual_hub_id`  | Outputs the ID of the created Azure Virtual Hub.    |

### `provider.tf`

Configures the required providers for the Connectivity sub-module.

#### Providers

| Name                      | Description                                         |
|---------------------------|-----------------------------------------------------|
| `azurerm`                 | Configures the Azure RM provider.                   |

### `variables.tf`

Defines input variables for the Connectivity module.

#### Variables

| Name                               | Description                                                 |
|------------------------------------|-------------------------------------------------------------|
| `application_name`                 | Application or service name used for naming resources.      |
| `subscription_type`                | Type of subscription for tagging and management purposes.   |
| `environment`                      | Deployment environment (dev, test, prod).                   |
| `location`                         | Azure region where resources will be deployed.              |
| `tags`                             | Tags applied to all resources created by this module.       |
| `vwhub_address_prefix`             | Network address prefix for the Virtual Hub.                 |
| Additional variables for alerting, firewall configuration, and diagnostics.

## Conclusion

This Connectivity sub-module is a key component of the Terraform setup for managing Azure infrastructure, focusing on networking and security configurations. It ensures that the virtual network architecture is robust, secure, and compliant with organizational standards.
