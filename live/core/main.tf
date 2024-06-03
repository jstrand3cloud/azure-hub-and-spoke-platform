#------------------------------
# SUBSCRIPTION MODULES
#------------------------------

#------------------------------
# MANAGEMENT
#------------------------------
# NOTE: Management Subscription exports/outputs a Log Analytics Workspace used by all other subscriptions

module "management_subscription" {
  providers = {
    azurerm = azurerm.management-sub
  }
  source                                      = "./subscriptions/management"
  #count                                       = var.enable_management_subscription == true ? 1 : 0
  application_name                            = var.application_name
  subscription_type                           = local.subscription_types.management
  environment                                 = var.environment
  location                                    = var.location
  #instance_number                            = var.instance_number
  tags                                        = var.tags
  email                                       = var.email
  cloudops_email                              = var.cloudops_email
  infosec_email                               = var.infosec_email
  cloudbudget_email                           = var.cloudbudget_email
  management_vnet_address_space               = var.management_vnet_address_space
  kvmgmt_subnet_address_prefixes              = var.kvmgmt_subnet_address_prefixes
  nsgflow_subnet_address_prefixes             = var.nsgflow_subnet_address_prefixes
  tfstate_subnet_address_prefixes             = var.tfstate_subnet_address_prefixes
  ado_pipeline_agents_subnet_address_prefixes = var.ado_pipeline_agents_subnet_address_prefixes
  bastion_subnet_address_prefixes             = var.bastion_subnet_address_prefixes
  ado_virtual_machines                        = var.ado_virtual_machines
  kvmgmt_network_security_group_rules         = merge(var.kvmgmt_network_security_group_rules, var.default_network_security_group_rules)
  tfstate_subnet_network_security_group_rules = merge (var.tfstate_subnet_network_security_group_rules, var.default_network_security_group_rules)
  nsgflow_subnet_network_security_group_rules = merge(var.nsgflow_subnet_network_security_group_rules, var.default_network_security_group_rules)
  ado_pipeline_agents_subnet_network_security_group_rules = merge(var.ado_pipeline_agents_subnet_network_security_group_rules, var.default_network_security_group_rules)
  bastion_subnet_network_security_group_rules = merge (var.bastion_subnet_network_security_group_rules, var.default_network_security_group_rules)
}

#------------------------------
# IDENTITY
#------------------------------

module "identity_subscription" {
  providers = {
    azurerm = azurerm.identity-sub
  }
  source                                = "./subscriptions/identity"
  application_name                      = var.application_name
  subscription_type                     = local.subscription_types.identity
  environment                           = var.environment
  location                              = var.location
  #instance_number                       = var.instance_number
  tags                                  = var.tags
  email                                 = var.email
  cloudops_email                        = var.cloudops_email
  infosec_email                         = var.infosec_email
  cloudbudget_email                     = var.cloudbudget_email
  log_analytics_workspace_id            = module.management_subscription.log_analytics_workspace_id
  log_analytics_workspace_workspace_id  = module.management_subscription.log_analytics_workspace_workspace_id
  log_analytics_workspace_location      = module.management_subscription.log_analytics_workspace_location
  log_analytics_workspace_key           = module.management_subscription.log_analytics_workspace_key
  cloudops_action_group_id              = module.management_subscription.cloudops_action_group_id
  identity_vnet_address_space           = var.identity_vnet_address_space
  kvid_subnet_address_prefixes          = var.kvid_subnet_address_prefixes
  addc_subnet_address_prefixes          = var.addc_subnet_address_prefixes
  infoblox_subnet_address_prefixes      = var.infoblox_subnet_address_prefixes
  pr_subnet_inbound_address_prefixes    = var.pr_subnet_inbound_address_prefixes
  pr_subnet_outbound_address_prefixes   = var.pr_subnet_outbound_address_prefixes
  nsg_flow_log_storage_account_id       = module.management_subscription.storage_account_id
  kvid_network_security_group_rules     = merge(var.kvid_network_security_group_rules, var.default_network_security_group_rules)
  addc_network_security_group_rules     = merge(var.addc_network_security_group_rules, var.default_network_security_group_rules)
  infoblox_network_security_group_rules = merge(var.infoblox_network_security_group_rules, var.default_network_security_group_rules)
  dnspr_network_security_group_rules    = merge(var.dnspr_network_security_group_rules, var.default_network_security_group_rules)
  depends_on                            = [ module.management_subscription ]
}

#------------------------------
# CONNECTIVITY
#------------------------------
# NOTE: Connectivity acts as a "hub", with DevTest and Production being "spokes"

module "connectivity_subscription" {
  providers = {
   azurerm = azurerm.connectivity-sub
  }
  source                                  = "./subscriptions/connectivity"
  application_name                        = var.application_name
  subscription_type                       = local.subscription_types.connectivity
  environment                             = var.environment
  location                                = var.location
  #instance_number                        = var.instance_number
  tags                                    = var.tags
  email                                   = var.email
  cloudops_email                          = var.cloudops_email
  infosec_email                           = var.infosec_email
  cloudbudget_email                       = var.cloudbudget_email
  vwhub_address_prefix                    = var.vwhub_address_prefix
  connectivity_vwhub_firewall_dns_servers = var.connectivity_vwhub_firewall_dns_servers
  log_analytics_workspace_id              = module.management_subscription.log_analytics_workspace_id
  log_analytics_workspace_workspace_id    = module.management_subscription.log_analytics_workspace_workspace_id
  log_analytics_workspace_location        = module.management_subscription.log_analytics_workspace_location
  log_analytics_workspace_key             = module.management_subscription.log_analytics_workspace_key
  cloudops_action_group_id                = module.management_subscription.cloudops_action_group_id
  depends_on                              = [ module.management_subscription ]
}

#------------------------------
# tbd DEVELOPMENT 01
#------------------------------

module "alz-tbd-dev-01_subscription" {
  providers = {
    azurerm = azurerm.alz-tbd-dev-01-sub
  }
  source                                              = "./subscriptions/alz-tbd-dev-01"
  application_name                                    = var.application_name
  subscription_type                                   = local.subscription_types.alz-tbd-dev-01
  environment                                         = local.environment.alz-tbd-dev-01
  location                                            = var.location
  #instance_number                                    = var.instance_number
  tags                                                = var.tags
  email                                               = var.email
  cloudops_email                                      = var.cloudops_email
  infosec_email                                       = var.infosec_email
  cloudbudget_email                                   = var.cloudbudget_email
  tbddev01_vnet_address_space                        = var.tbddev01_vnet_address_space
  apptbddev01_subnet_address_prefixes                = var.apptbddev01_subnet_address_prefixes
  apptbddev01_subnet_network_security_group_rules    = merge(var.apptbddev01_subnet_network_security_group_rules, var.default_network_security_group_rules)
  datatbddev01_subnet_address_prefixes               = var.datatbddev01_subnet_address_prefixes
  datatbddev01_subnet_network_security_group_rules   = merge(var.datatbddev01_subnet_network_security_group_rules, var.default_network_security_group_rules)
  petbddev01_subnet_address_prefixes                 = var.petbddev01_subnet_address_prefixes
  petbddev01_subnet_network_security_group_rules     = merge(var.petbddev01_subnet_network_security_group_rules, var.default_network_security_group_rules)
  kvtbddev01_subnet_address_prefixes                 = var.kvtbddev01_subnet_address_prefixes
  kvtbddev01_subnet_network_security_group_rules     = merge(var.kvtbddev01_subnet_network_security_group_rules, var.default_network_security_group_rules)
  nsg_flow_log_storage_account_id                     = module.management_subscription.storage_account_id
  log_analytics_workspace_id                          = module.management_subscription.log_analytics_workspace_id
  log_analytics_workspace_workspace_id                = module.management_subscription.log_analytics_workspace_workspace_id
  log_analytics_workspace_location                    = module.management_subscription.log_analytics_workspace_location
  log_analytics_workspace_key                         = module.management_subscription.log_analytics_workspace_key
  cloudops_action_group_id                            = module.management_subscription.cloudops_action_group_id
  management_kv_dns_zone_id                           = module.management_subscription.management_kv_dns_zone_id
  depends_on                                          = [ module.management_subscription, module.identity_subscription ]
}


#------------------------------
# VIRTUAL WAN CONNECTIONS
#------------------------------

# TODO: these resource calls needs to be turned into modules

resource "azurerm_virtual_hub_connection" "mgmt-spoke-connection" {
  name                      = "conn-mgmt-vnet-to-vwhub"
  provider                  = azurerm.connectivity-sub
  virtual_hub_id            = module.connectivity_subscription.azurerm_virtual_hub_id
  remote_virtual_network_id = module.management_subscription.virtual_network_mgmt_id
  internet_security_enabled = true
  depends_on                   = [
     module.connectivity_subscription, 
     module.management_subscription
   ]
}

resource "azurerm_virtual_hub_connection" "identity-spoke-connection" {
  name                      = "conn-identity-vnet-to-vwhub"
  provider                  = azurerm.connectivity-sub
  virtual_hub_id            = module.connectivity_subscription.azurerm_virtual_hub_id
  remote_virtual_network_id = module.identity_subscription.virtual_network_identity_id
  internet_security_enabled = true
    depends_on                   = [
     module.connectivity_subscription, 
     module.identity_subscription
   ]
}

resource "azurerm_virtual_hub_connection" "alz-tbd-dev-01-spoke-connection" {
  name                      = "conn-tbd-dev-01-vnet-to-vwhub"
  provider                  = azurerm.connectivity-sub
  virtual_hub_id            = module.connectivity_subscription.azurerm_virtual_hub_id
  remote_virtual_network_id = module.alz-tbd-dev-01_subscription.virtual_network_tbddev01_id
  internet_security_enabled = true
    depends_on                   = [
     module.connectivity_subscription, 
     module.alz-tbd-dev-01_subscription
   ]
}