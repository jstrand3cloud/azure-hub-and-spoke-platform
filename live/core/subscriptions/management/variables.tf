#------------------------------
# VARIABLES
#------------------------------

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
  description = "Environment: dev, test, prod"
  default     = "dev"
}
variable "location" {
  description = "Azure Location (see: https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#overview)"
  default     = "eastus2"
}
# variable "instance_number" {
#   description = "Instance Number: 001, 002, ..., 998, 999"
#   default     = "001"
# }

#NOTE: Currently "instance_number" variable is removed due to not needing it at this time.

#------------------------------
# TAGGING VARIABLES
#------------------------------

variable "tags" {
  type = object({
    project_name           = string
    department             = string
    environment            = string
    operations_contact     = string
    cost_center            = string
    owner                  = string
    #data_classification_type = string
    
  })
  default = {
    project_name              = "landing zone core"
    department                = "infra"
    environment               = "prod"
    terraform                 = "managed"
    operations_contact        = "opsteamname - support@tbd.org"
    cost_center               = "11228"
    owner                     = "tbd@tbd.org"
    #data_classification_type = "Public"
  }
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
# SECURITY CENTER / DEFENDER FOR CLOUD / LOG ANALYTICS
#------------------------------

variable "email" {}
variable "log_alert_name" {
  default = "management_service_health_alert"
}

#------------------------------
# ACTION GROUPS VARIABLES
#------------------------------

variable "cloudops_email" {}
variable "infosec_email" {}
variable "cloudbudget_email" {}

#------------------------------
# VIRTUAL NETWORK AND SUBNET ADDRESSES
#------------------------------

variable "management_vnet_address_space" {}
variable "kvmgmt_subnet_address_prefixes" {}
variable "nsgflow_subnet_address_prefixes" {}
variable "tfstate_subnet_address_prefixes" {}
variable "ado_pipeline_agents_subnet_address_prefixes" {}
variable "bastion_subnet_address_prefixes" {}


#------------------------------
# NETWORK SECURITY GROUP (NSG) RULES
#------------------------------

variable "kvmgmt_network_security_group_rules" {}
variable "nsgflow_subnet_network_security_group_rules" {}
variable "tfstate_subnet_network_security_group_rules" {}
variable "ado_pipeline_agents_subnet_network_security_group_rules" {}
variable "bastion_subnet_network_security_group_rules" {}

#----------------------------------------
# ADO SELF HOSTED AGENT VIRTUAL MACHINES
#----------------------------------------

variable "ado_virtual_machines" {
  description = "Name and details of the virtual machines to be created"
}