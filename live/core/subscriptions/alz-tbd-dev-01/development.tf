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

#Primary resource groups for services in the development Subscription.

module "resource_group_shared" {
  source            = "../../../../../terraform_modules/resource_group"
  #name_override     = "rg-shared-dt-dev-eastus-001"
  application_name  = local.application_names.resource_group_shared # var.application_name
  subscription_type = var.subscription_type                         # "dt"        
  environment       = var.environment                               # "dev"                
  location          = var.location                                  # "eastus"                
  instance_number   = var.instance_number                           # "001"            
  tags              = var.tags
}

module "resource_group_alert_rules" {
  source            = "../../../../../terraform_modules/resource_group"
  #name_override     = "rg-alert_rules"
  application_name  = local.application_names.resource_group_alert_rules #var.application_name 
  subscription_type = var.subscription_type                         # "conn"        
  environment       = var.environment                               # "dev"                
  location          = var.location                                  # "eastus"                
  instance_number   = var.instance_number                           # "001"            
  tags              = var.tags
}

#------------------------------
# VIRTUAL NETWORK (VNET)
#------------------------------

module "virtual_network_tbddev01" {
  source              = "../../../../../terraform_modules/network/virtual_network"
  #name_override       = "vnet-spoke-dt-dev-eastus-001"
  application_name    = local.application_names.virtual_network_tbddev01
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags 
  resource_group_name = module.resource_group_shared.name
  address_space       = var.tbddev01_vnet_address_space
  #address_space       = ["172.20.20.0/22"]
}

module "virtual_network_tbddev01_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.virtual_network_tbddev01_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.virtual_network_tbddev01.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

#------------------------------
# APPLICATIONS SUBNET
#------------------------------

module "apptbddev01_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.apptbddev01_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_shared.name
  virtual_network_name  = module.virtual_network_tbddev01.name
  address_prefixes      = var.apptbddev01_subnet_address_prefixes
  #address_prefixes      = ["172.20.1.0/28"]
  depends_on            = [ module.virtual_network_tbddev01 ]
}

module "apptbddev01_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.apptbddev01_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_shared.name
}

module "apptbddev01_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.apptbddev01_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.apptbddev01_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "apptbddev01_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_shared.name
  network_security_group_name   = module.apptbddev01_subnet_network_security_group.name
  network_security_group_rules  = var.apptbddev01_subnet_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "apptbddev01_network_security_group_association" {
  subnet_id                 = module.apptbddev01_subnet.id
  network_security_group_id = module.apptbddev01_subnet_network_security_group.id
}

#------------------------------
# DATA SUBNET
#------------------------------

module "datatbddev01_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.datatbddev01_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_shared.name
  virtual_network_name  = module.virtual_network_tbddev01.name
  address_prefixes      = var.datatbddev01_subnet_address_prefixes
  #address_prefixes      = ["172.20.1.0/28"]
  depends_on            = [ module.virtual_network_tbddev01 ]
}

module "datatbddev01_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.datatbddev01_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_shared.name
}

module "datatbddev01_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.datatbddev01_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.datatbddev01_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "datatbddev01_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_shared.name
  network_security_group_name   = module.datatbddev01_subnet_network_security_group.name
  network_security_group_rules  = var.datatbddev01_subnet_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "datatbddev01_network_security_group_association" {
  subnet_id                 = module.datatbddev01_subnet.id
  network_security_group_id = module.datatbddev01_subnet_network_security_group.id
}

#------------------------------
# PRIVATE ENDPOINT SUBNET
#------------------------------

module "petbddev01_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.petbddev01_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_shared.name
  virtual_network_name  = module.virtual_network_tbddev01.name
  address_prefixes      = var.petbddev01_subnet_address_prefixes
  #address_prefixes      = ["172.20.1.0/28"]
  depends_on            = [ module.virtual_network_tbddev01 ]
}

module "petbddev01_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.petbddev01_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_shared.name
}

module "petbddev01_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.petbddev01_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.petbddev01_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "petbddev01_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_shared.name
  network_security_group_name   = module.petbddev01_subnet_network_security_group.name
  network_security_group_rules  = var.petbddev01_subnet_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "petbddev01_network_security_group_association" {
  subnet_id                 = module.petbddev01_subnet.id
  network_security_group_id = module.petbddev01_subnet_network_security_group.id
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
  instance_number   = var.instance_number      
  tags              = var.tags
}

module "kvtbddev01_subnet" {
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.kvtbddev01_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_shared.name
  virtual_network_name  = module.virtual_network_tbddev01.name
  address_prefixes      = var.kvtbddev01_subnet_address_prefixes
  #address_prefixes      = ["72.20.99.0/28"] 
  service_endpoints     = [ "Microsoft.KeyVault" ]
  depends_on            = [ module.virtual_network_tbddev01 ]
}

# #NSG for the Key Vault subnet
module "kvtbddev01_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.kvtbddev01_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_shared.name
}

# #Diagnostic settings for the Key Vault
module "kvtbddev01_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.kvtbddev01_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.kvtbddev01_subnet_network_security_group.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "kvtbddev01_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_shared.name
  network_security_group_name   = module.kvtbddev01_subnet_network_security_group.name
  network_security_group_rules  = var.kvtbddev01_subnet_network_security_group_rules
}

# # TODO: this resource call needs to be turned into a module
# #Associates the NSG with the Key Vault subnet
resource "azurerm_subnet_network_security_group_association" "kvtbddev01_network_security_group_association" {
  subnet_id                 = module.kvtbddev01_subnet.id
  network_security_group_id = module.kvtbddev01_subnet_network_security_group.id
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
  public_network_access_enabled = true
  #allowed_network_subnet_ids = ["module.kv_subnet.id", "module.ado_pipeline_agents_subnet.id"]  #Must fix this before using Key Vaults
}

# Create key vault Private Endpoint
resource "azurerm_private_endpoint" "kv_sta_pe" {
  name                = "pe-kv-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_key_vault.name
  location            = var.location
  subnet_id           = module.kvtbddev01_subnet.id

  private_service_connection {
    name                           = "tbddev01-privateserviceconnection"
    private_connection_resource_id = module.key_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "kv-dns_zone"
    private_dns_zone_ids = [var.management_kv_dns_zone_id]
  }
  depends_on = [time_sleep.wait_30_seconds]
}

#Diagnostic settings for the Key Vault
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

# #------------------------------
# # LOG ANALYTICS WORKSPACE
# #------------------------------

module "log_analytics_workspace" {
  source              = "../../../../../terraform_modules/log_analytics_workspace"
  #name_override       = "log-shared-dt-dev-eastus-001"
  application_name    = local.application_names.log_analytics_workspace
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location
  retention_in_days   = 180 
  #instance_number     = var.instance_number
  tags                = var.tags   
  resource_group_name = module.resource_group_shared.name
}

module "log_analytics_workspace_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = "ds-log-mgmt-dev-eastus-001"
  application_name            = local.application_names.log_analytics_workspace_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.log_analytics_workspace.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
  #depends_on                  = [ module.security_center ]
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
  depends_on          = [ module.virtual_network_tbddev01 ]
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
    module.virtual_network_tbddev01,
    module.apptbddev01_subnet_network_security_group,
    module.datatbddev01_subnet_network_security_group,
    module.petbddev01_subnet_network_security_group,
    module.kvtbddev01_subnet_network_security_group
  ]
}

# #------------------------------
# # ALERTS
# #------------------------------

# TODO: create module for this resource call and bring variables up to standard with the rest of the modules
resource "azurerm_monitor_action_group" "tbddev01_action_group" {
  name                = "ag-${var.subscription_type}-${var.environment}-${var.location}-${var.instance_number}"
  resource_group_name = module.resource_group_shared.name
  short_name          = "${var.subscription_type}"
  email_receiver {
    name                    = "sendtocloudops"
    email_address           = var.cloudops_email
    use_common_alert_schema = true
  }
}

# TODO: update this module to be up to standard with the rest of the modules
module "tbddev01_activity_log_alert" {
  source                              = "../../../../../terraform_modules/monitor_activity_log_alert"
  log_alert_name                      = var.log_alert_name
  resource_group_name                 = module.resource_group_shared.name
  log_alert_scopes                    = [data.azurerm_subscription.current.id]
  log_alert_description               = "This activity log alert is to monitor the health of all services in the ${var.subscription_type}-${var.environment}-${var.instance_number} subsciption"
  log_alert_enabled                   = true
  criteria_category                   = "ServiceHealth"
  service_health_locations            = [var.location]
  action_group_id                     = var.cloudops_action_group_id
  tags                                = var.tags
}
