#------------------------------
# DEFENDER FOR CLOUD
#------------------------------

resource "azurerm_security_center_contact" "defender_default_contact" {
  email = var.infosec_email

  alert_notifications = true
  alerts_to_admins    = true
}

#------------------------------
# SLEEP TIMER
#------------------------------

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}

#------------------------------
# SUBSCRIPTION ACTIVITY LOGS DIAGNOSTIC SETTINGS
#------------------------------

resource "azurerm_monitor_diagnostic_setting" "subscription_activity_logs_diagnostic_settings" {
    name                           = "ds-${var.subscription_type}-${var.environment}-${var.location}"
    target_resource_id             = data.azurerm_subscription.current.id
    log_analytics_workspace_id     = var.log_analytics_workspace_id
dynamic "enabled_log" {
    for_each = toset( ["Administrative", "Security", "ServiceHealth", "Alert", "Recommendation", "Policy", "Autoscale", "ResourceHealth"] )

    content {
      category = enabled_log.value
    }
  }

  lifecycle {
    ignore_changes = [enabled_log, log, metric, target_resource_id]
  }
}

#------------------------------
# MAIN RESOURCE GROUPS
#------------------------------

#Primary resource groups for services in the Identity Subscription.

module "resource_group_identity" {
  source            = "../../../../../terraform_modules/resource_group"
  #name_override     = ""
  application_name  = local.application_names.resource_group_identity # var.application_name
  subscription_type = var.subscription_type                         # "id"        
  environment       = var.environment                               # "dev"                
  location          = var.location                                  # "eastus"                
  #instance_number   = var.instance_number                           # "001"            
  tags              = var.tags
}

module "resource_group_alert_rules" {
  source            = "../../../../../terraform_modules/resource_group"
  #name_override     = "rg-alert_rules"
  application_name  = local.application_names.resource_group_alert_rules #var.application_name 
  subscription_type = var.subscription_type                         # "conn"        
  environment       = var.environment                               # "dev"                
  location          = var.location                                  # "eastus"                
  #instance_number   = var.instance_number                           # "001"            
  tags              = var.tags
}

#------------------------------
# VIRTUAL NETWORK (VNET)
#------------------------------

module "virtual_network_identity" {
  source              = "../../../../../terraform_modules/network/virtual_network"
  #name_override       = ""
  application_name    = local.application_names.virtual_network_identity
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
 #instance_number     = var.instance_number  
  tags                = var.tags 
  resource_group_name = module.resource_group_identity.name
  address_space       = var.identity_vnet_address_space
  #address_space       = ["172.20.1.0/24"]
}

module "virtual_network_identity_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.virtual_network_identity_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.virtual_network_identity.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

#------------------------------
# KEY VAULT
#------------------------------

module "resource_group_key_vault" {
  source            = "../../../../../terraform_modules/resource_group"
  #name_override     = ""
  application_name  = local.application_names.resource_group_key_vault
  subscription_type = var.subscription_type       
  environment       = var.environment              
  location          = var.location          
  #instance_number   = var.instance_number      
  tags              = var.tags
}

module "kv_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.kv_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_identity.name
  virtual_network_name  = module.virtual_network_identity.name
  address_prefixes      = var.kvid_subnet_address_prefixes
  #address_prefixes      = ["172.20.1.0/28"]
  service_endpoints     = [ "Microsoft.KeyVault" ]
  depends_on            = [ module.virtual_network_identity ]
}

module "kvid_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.kvid_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_identity.name
}

module "kvid_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.kvid_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.kvid_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "kvid_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_identity.name
  network_security_group_name   = module.kvid_subnet_network_security_group.name
  network_security_group_rules  = var.kvid_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "kvid_network_security_group_association" {
  subnet_id                 = module.kv_subnet.id
  network_security_group_id = module.kvid_subnet_network_security_group.id
}

module "key_vault" {
  source              = "../../../../../terraform_modules/key_vault"
  #name_override       = "kv-shared-mgmt-dev-XX"  # NOTE: XX = 2 random hex characters, key vaults can only be 24 characters max
  application_name    = local.application_names.key_vault
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number      
  tags                = var.tags
  resource_group_name = module.resource_group_key_vault.name
  public_network_access_enabled = false
  #allowed_network_subnet_ids = ["module.kv_subnet.id"]  #Must fix this before using Key Vaults
}

# TODO: this resource call needs to be turned into a module
# Create key vault Private Endpoint
resource "azurerm_private_endpoint" "kv_sta_pe" {
  name                = "pe-kv-id-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_key_vault.name
  location            = var.location
  subnet_id           = module.kv_subnet.id

  private_service_connection {
    name                           = "identity-privateserviceconnection" 
    private_connection_resource_id = module.key_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "kv-dns_zone"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault_dns_zone.id]
  }
  depends_on = [time_sleep.wait_30_seconds]
}

module "key_vault_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = "ds-kv-mgmt-dev-eastus-001"
  application_name            = local.application_names.key_vault_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.key_vault.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

################################## Keyvault DNS zone #####################################
resource "azurerm_private_dns_zone" "keyvault_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.resource_group_key_vault.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_spoke_vnet_link" {
  name                  = "keyvault_id_vnet_link"
  resource_group_name = module.resource_group_key_vault.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns_zone.name
  virtual_network_id    = module.virtual_network_identity.id
}

#------------------------------
# ACTIVE DIRECTORY DOMAIN CONTROLLER SUBNET
#------------------------------

module "addc_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.addc_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_identity.name
  virtual_network_name  = module.virtual_network_identity.name
  address_prefixes      = var.addc_subnet_address_prefixes
  #address_prefixes      = ["172.20.1.0/28"]
  depends_on            = [ module.virtual_network_identity ]
}

module "addc_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.addc_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_identity.name
}

module "addc_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.addc_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.addc_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "addc_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_identity.name
  network_security_group_name   = module.addc_subnet_network_security_group.name
  network_security_group_rules  = var.addc_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "addc_network_security_group_association" {
  subnet_id                 = module.addc_subnet.id
  network_security_group_id = module.addc_subnet_network_security_group.id
}

#------------------------------
# INFOBLOX SUBNET
#------------------------------

module "infoblox_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.infoblox_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_identity.name
  virtual_network_name  = module.virtual_network_identity.name
  address_prefixes      = var.infoblox_subnet_address_prefixes
  #address_prefixes      = ["172.20.1.0/28"]
  depends_on            = [ module.virtual_network_identity ]
}

module "infoblox_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.infoblox_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_identity.name
}

module "infoblox_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.infoblox_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.infoblox_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "infoblox_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_identity.name
  network_security_group_name   = module.infoblox_subnet_network_security_group.name
  network_security_group_rules  = var.infoblox_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "infoblox_network_security_group_association" {
  subnet_id                 = module.infoblox_subnet.id
  network_security_group_id = module.infoblox_subnet_network_security_group.id
}

#------------------------------
# PRIVATE RESOLVER (DNS)
#------------------------------

# TODO: this resource call needs to be turned into a module
# Private Resolver Service
resource "azurerm_private_dns_resolver" "dns_resolver" {
  name                = "dnspr-shared-id-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_identity.name
  location            = var.location
  virtual_network_id  = module.virtual_network_identity.id
  tags              = var.tags
}

module "pr_subnet_inbound" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.pr_subnet_inbound
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_identity.name
  virtual_network_name  = module.virtual_network_identity.name
  address_prefixes      = var.pr_subnet_inbound_address_prefixes
  #address_prefixes      = ["172.20.1.16/28"]
  #service_endpoints     = [ "Microsoft.Storage" ]
  delegation_name       = "Microsoft.Network.dnsResolvers"
  delegation_actions    = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  delegation_service    = "Microsoft.Network/dnsResolvers"
  depends_on            = [ module.virtual_network_identity ]
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_private_dns_resolver_inbound_endpoint" "dnspr_pe_in" {
  name                    = "dnspr-pe-in"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  location                = var.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = module.pr_subnet_inbound.id
    #private_ip_address           = "172.0.5.20"
  }
}

module "prinbound_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.prinbound_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_identity.name
}

module "prinbound_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.prinbound_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.prinbound_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "prinbound_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_identity.name
  network_security_group_name   = module.prinbound_subnet_network_security_group.name
  network_security_group_rules  = var.dnspr_network_security_group_rules
}

module "pr_subnet_outbound" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.pr_subnet_outbound
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_identity.name
  virtual_network_name  = module.virtual_network_identity.name
  address_prefixes      = var.pr_subnet_outbound_address_prefixes
  #address_prefixes      = ["172.20.1.32/28"] 
  #service_endpoints     = [ "Microsoft.Storage" ]
  delegation_name       = "Microsoft.Network.dnsResolvers"
  delegation_actions    = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  delegation_service    = "Microsoft.Network/dnsResolvers"
  depends_on            = [ module.virtual_network_identity ]
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_private_dns_resolver_outbound_endpoint" "dnspr_pe_out" {
  name                    = "dnspr-pe-out"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  location                = var.location
  subnet_id               = module.pr_subnet_outbound.id
}

module "proutbound_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.proutbound_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_identity.name
}

module "proutbound_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.proutbound_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.proutbound_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "proutbound_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_identity.name
  network_security_group_name   = module.proutbound_subnet_network_security_group.name
  network_security_group_rules  = var.dnspr_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "prinbound_network_security_group_association" {
  subnet_id                 = module.pr_subnet_inbound.id
  network_security_group_id = module.prinbound_subnet_network_security_group.id
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "proutbound_network_security_group_association" {
  subnet_id                 = module.pr_subnet_outbound.id
  network_security_group_id = module.proutbound_subnet_network_security_group.id
}


#------------------------------
# NETWORK SECURITY GROUPS (NSGs)
#------------------------------

# # Get current Network Watcher
# # NOTE: This is expecting the default: 
# #   - Network Watcher Resource Group ("NetworkWatcherRG")
# #   - Network Watcher Resource Name ("NetworkWatcher_<location>")
# # Edit this if the Azure subscription/tenant has opted out of automatic Network Watcher creation 
# #   (see: https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-create)
data "azurerm_network_watcher" "current" {
  name                = "NetworkWatcher_${var.location}"
  resource_group_name = "NetworkWatcherRG"
  depends_on          = [ module.virtual_network_identity ]
}

# TODO: Bring this module up to the standards of the other modules
module "network_security_group_flow_logs" {
  source                    = "../../../../../terraform_modules/network/network_security_group_flow_logs"
  for_each                  = local.network_security_groups
  application_name          = each.key
  subscription_type         = var.subscription_type       
  environment               = var.environment              
  location                  = data.azurerm_network_watcher.current.location          
  #instance_number           = var.instance_number  
  tags                      = var.tags 
  network_watcher_name      = data.azurerm_network_watcher.current.name
  resource_group_name       = data.azurerm_network_watcher.current.resource_group_name
  network_security_group_id = each.value
  storage_account_id        = var.nsg_flow_log_storage_account_id
  enabled                   = true
  nsgflow_version           = "2"
  retention_policy = {
    rp1 = {
      days    = "90"
      enabled = true
    }
  }
  traffic_analytics = {
    ta1 = {
      enabled               = true
      interval_in_minutes   = "10"
      workspace_id          = var.log_analytics_workspace_workspace_id
      workspace_region      = var.log_analytics_workspace_location
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }
  depends_on = [
    module.virtual_network_identity,
    module.kvid_subnet_network_security_group,
    module.prinbound_subnet_network_security_group,
    module.proutbound_subnet_network_security_group
  ]
}

#------------------------------
# ALERTS
#------------------------------

# # TODO: create module for this resource call and bring variables up to standard with the rest of the modules
resource "azurerm_monitor_action_group" "identity_action_group" {
  name                = "ag-${var.subscription_type}-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_identity.name
  short_name          = "${var.subscription_type}"
  email_receiver {
    name                    = "sendtocloudops"
    email_address           = var.cloudops_email
    use_common_alert_schema = true
  }
}

# TODO: update this module to be up to standard with the rest of the modules
module "identity_activity_log_alert" {
  source                              = "../../../../../terraform_modules/monitor_activity_log_alert"
  log_alert_name                      = var.log_alert_name
  resource_group_name                 = module.resource_group_identity.name
  log_alert_scopes                    = [data.azurerm_subscription.current.id]
  log_alert_description               = "This activity log alert is to monitor the health of all services in the ${var.subscription_type} subsciption"
  log_alert_enabled                   = true
  criteria_category                   = "ServiceHealth"
  service_health_locations            = [var.location]
  action_group_id                     = var.cloudops_action_group_id
  tags                                = var.tags
}