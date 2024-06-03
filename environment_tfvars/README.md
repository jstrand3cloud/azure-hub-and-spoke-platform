# ALZ Core Configuration Variables Overview

## Introduction

This document provides a high-level overview of the `alzcore.tfvars` used for configuring the Azure Landing Zone (ALZ). This configuration file is pivotal for tailoring the deployment to specific needs across various environments and subscriptions.

## Configuration Details

### Resource Naming Conventions

This section defines fundamental identifiers that will be used across all resources to ensure a consistent naming convention that aids in organization and management. These identifiers include:

- **Application Name**: Refers to the overarching service or application the resources are tied to, for instance, 'Landing Zone'.
- **Subscription Type**: Indicates the category of the Azure subscription, such as connectivity or identity, defining the purpose or the nature of the resources within it.
- **Environment**: Describes the stage of deployment, such as development or production, helping segregate and manage resources according to their lifecycle stage.
- **Location**: Specifies the Azure region where resources will be deployed, influencing data residency and latency considerations.

### Tags

Tags are key-value pairs attached to resources that help in categorizing resources for cost tracking, management, or automation:

- Tags like `project_name`, `department`, and `environment` are used to allocate costs accurately, simplify the organization of cloud assets, and automate or streamline operations specific to various departments and environments.

### Toggle Flags

Boolean flags to enable or disable specific configurations for each subscription type, facilitating modular and conditional deployment:

- These toggles allow the selective activation of resources per subscription, supporting tailored deployment strategies that align with business requirements, such as different resource needs for development (`enable_chicdev01_subscription`) versus production environments (`enable_chicprd01_subscription`).

### High Availability / Failover

Configuration settings related to the deployment architecture's resilience and availability:

- **Zones**: Defines the availability zones within the selected region to deploy resources, ensuring high availability and failover capabilities.

### Virtual Network / Subnet Addresses

Defines the network topology and IP range allocations for subnets across various subscriptions, crucial for network planning and segmentation:

- This includes settings for different environments, ensuring logical separation and proper network space allocation, such as isolated networks for development (`chicdev01_vnet_address_space`) and production (`chicprd01_vnet_address_space`).

### Network Security Group (NSG) Rules

Security configurations that govern the inbound and outbound network traffic to and from Azure resources:

- NSG rules are critical for defining the security boundaries of the network. Each rule set (e.g., `kvmgmt_network_security_group_rules`, `ado_pipeline_agents_subnet_network_security_group_rules`) is tailored to specific network interfaces, allowing precise control over traffic flow, which is essential for maintaining a secure and compliant environment.

#### Specific Rule Sets

Each NSG rule set is designed to cater to the specific requirements of different subnets associated with various roles and functions within the Azure environment.  Below you will find a more detailed explaination and some examples.

- **General Rules**: Common rules applied across all subnets, such as allowing outbound HTTPS traffic to ensure basic external connectivity and blocking all inbound traffic by default to enforce a secure perimeter.

- **Key Vault Subnet Rules** (`kvmgmt_network_security_group_rules`):
  - **HTTPS Allowance**: Inbound and outbound rules allow HTTPS (port 443) traffic to ensure secure communication with Azure Key Vault, which is critical for managing secrets, encryption keys, and certificates.
  - **Deny All Else**: Ensures that no other forms of traffic are permitted, which tightens security around sensitive operations.

- **ADO Pipeline Agents Subnet Rules** (`ado_pipeline_agents_subnet_network_security_group_rules`):
  - **HTTPS and DNS**: Allows essential HTTPS for secure web traffic and DNS (port 53) for name resolution which is necessary for agent operations and external service connectivity.
  - **RDP Access**: Inbound Remote Desktop Protocol (RDP) access (port 3389) is allowed for administrative purposes, providing controlled access to maintain the agents.

- **Bastion Subnet Rules** (`bastion_subnet_network_security_group_rules`):
  - **Specific Port Allowances**: Allows specific ports for Bastion host communications, which are necessary for secure, remote administrative access to other VMs within the network.
  - **Internet and Virtual Network Access**: Enables access from the internet under strict conditions (such as HTTPS only) and broad access within the virtual network to facilitate operations between the Bastion host and internal resources.

### ADO Self-Hosted Agent Virtual Machines

Configurations for Azure DevOps (ADO) self-hosted agents, detailing the virtual machine setup:

- Parameters like `size`, `storage_account_type`, and IP allocation strategy (`private_ip_address_allocation`) are specified, which determine the performance capabilities and networking behavior of these VMs.

## Conclusion

The `alzcore.tfvars` file serves as a centralized configuration source for deploying a tailored Azure Landing Zone. By adjusting these variables, administrators can manage multiple environments and subscriptions efficiently, ensuring each setup is optimized for its intended purpose while maintaining governance, compliance, and operational standards.
