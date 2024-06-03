#------------------------------
# VARIABLES
#------------------------------

#------------------------------
# AZURE TENANT/CLIENT/SUBSCRIPTIONS
#------------------------------

# NOTE: no defaults are provided to ensure error or interactive prompt if not provided

# Azure Tenant ID
# variable "tenant_id" {
#   description = "Tenant ID"
# }

# # Service Principle (SPN) ID and Secret
# variable "client_id" {
#   description = "Client ID"
# }
# variable "client_secret" {
#   description = "Client Secret"
# }

#------------------------------
# BACKEND_TFVARS VARIABLES
#------------------------------

variable "resource_group_name" {
  description = "The name of the resource group containing the storage account for Terraform state files"
  type = string
}
variable "storage_account_name" {
  description = "The name of the storage account for Terraform state files"
  type = string
}
variable "container_name" {
  description = "The name of the storage container for Terraform state files"
  type = string
}

#------------------------------
# SUBSCRIPTION IDS
#------------------------------

variable "connectivity_subscription_id" {
  description = "Connectivity Subscription ID"
}
variable "identity_subscription_id" {
  description = "Identity Subscription ID"
}
variable "management_subscription_id" {
  description = "Management Subscription ID"
}
variable "alz-tbd-dev-01_subscription_id" {
  description = "tbd Development 01 Subscription ID"
}

#------------------------------
# RESOURCE NAMING CONVENTIONS
#------------------------------

# Application, Subscription, Location, Environment, and Instance Number.  (i.e sharepoint-prod-westus-001)
# NOTE: these values are used to create names for resources and resource groups (please be mindful of character length limits)

variable "application_name" {
  description = "Application or Service Name"
  default     = "demo"
}
variable "subscription_type" {
  description = "Subscription Type: conn (connectivity), dt (devtest), id (identity), mgmt (management), prod (production), shared (any)"
  default     = "shared"
}
variable "environment" {
  description = "Environment: dev, tst, prd"
  default     = "dev"
}
variable "location" {
  description = "Azure Location (see: https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#overview)"
  default     = "eastus"
}
# variable "instance_number" {
#   description = "Instance Number: 001, 002, ..., 998, 999"
#   default     = "001"
# }

#------------------------------
# TAGGING VARIABLES
#------------------------------

variable "tags" {
  type = object({
    project_name           = string
    department             = string
    environment            = string
    terraform              = string
    operations_contact     = string
    cost_center            = string
    owner                  = string
    #data_classification_type = string
      
  })
  default = {
    project_name              = "landing zone core"
    department                = "infra"
    environment               = "prd"
    terraform                 = "managed"
    operations_contact        = "opsteamname - support@tbd.org"
    cost_center               = "11228"
    owner                     = "tbd@tbd.org"
    #data_classification_type = "Public"
  }
}

#------------------------------
# TOGGLES
#------------------------------

variable "enable_connectivity_subscription"  {
  default = true 
}
variable "enable_identity_subscription"  {
  default = true 
}
variable "enable_management_subscription"  {
  default = true 
}
variable "enable_tbddev01_subscription"  {
  default = true 
}

#------------------------------
# HIGH AVAILABILITY / FAILOVER
#------------------------------

# Availability Zones
variable "zones" {
  type    = list
  default = [ "1", "2", "3" ]
}

#------------------------------
# SECURITY CENTER / DEFENDER FOR CLOUD
#------------------------------

variable "email" {}

#------------------------------
# ACTION GROUPS VARIABLES
#------------------------------

variable "cloudops_email" {}
variable "infosec_email" {}
variable "cloudbudget_email" {}

#------------------------------
# VIRTUAL NETWORK / SUBNET ADDRESSES
#------------------------------

# Connectivity
variable "vwhub_address_prefix" {}

# Management
variable "management_vnet_address_space" {}
variable "kvmgmt_subnet_address_prefixes" {}
variable "nsgflow_subnet_address_prefixes" {}
variable "tfstate_subnet_address_prefixes" {}
variable "ado_pipeline_agents_subnet_address_prefixes" {}
variable "bastion_subnet_address_prefixes" {}

# Identity
variable "identity_vnet_address_space" {}
variable "kvid_subnet_address_prefixes" {}
variable "addc_subnet_address_prefixes" {}
variable "infoblox_subnet_address_prefixes" {}
variable "pr_subnet_inbound_address_prefixes" {}
variable "pr_subnet_outbound_address_prefixes" {}

# tbddev01
variable "tbddev01_vnet_address_space" {}
variable "apptbddev01_subnet_address_prefixes" {}
variable "datatbddev01_subnet_address_prefixes" {}
variable "petbddev01_subnet_address_prefixes" {}
variable "kvtbddev01_subnet_address_prefixes" {}

#------------------------------
# NETWORK SECURITY GROUP (NSG) RULES
#------------------------------

# All
variable "default_network_security_group_rules" {}

# Management
variable "kvmgmt_network_security_group_rules" {}
variable "nsgflow_subnet_network_security_group_rules" {}
variable "tfstate_subnet_network_security_group_rules" {}
variable "ado_pipeline_agents_subnet_network_security_group_rules" {}
variable "bastion_subnet_network_security_group_rules" {}

# Identity
variable "kvid_network_security_group_rules" {}
variable "addc_network_security_group_rules" {}
variable "infoblox_network_security_group_rules" {}
variable "dnspr_network_security_group_rules" {}

# tbddev01
variable "apptbddev01_subnet_network_security_group_rules" {}
variable "datatbddev01_subnet_network_security_group_rules" {}
variable "petbddev01_subnet_network_security_group_rules" {}
variable "kvtbddev01_subnet_network_security_group_rules" {}

#------------------------------
# FIREWALL DNS SERVERS
#------------------------------

variable "connectivity_vwhub_firewall_dns_servers" {}

#----------------------------------------
# ADO SELF HOSTED AGENT VIRTUAL MACHINES
#----------------------------------------

variable "ado_virtual_machines" {
  description = "Name and details of the virtual machines to be created"
}