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
    log_analytics_workspace_id     = module.log_analytics_workspace.id
dynamic "enabled_log" {
    for_each = toset( ["Administrative", "Security", "ServiceHealth", "Alert", "Recommendation", "Policy", "Autoscale", "ResourceHealth"] )
# dynamic "enabled_log" {
#     for_each = var.logs_categories

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

#Primary resource groups for services in the Management Subscription.

module "resource_group_mgmt" {
  source            = "../../../../../terraform_modules/resource_group"
  #name_override     = ""
  application_name  = local.application_names.resource_group_mgmt #var.application_name 
  subscription_type = var.subscription_type                         # "conn"        
  environment       = var.environment                               # "dev"                
  location          = var.location                                  # "eastus"                
  #instance_number   = var.instance_number                           # "001"            
  tags              = var.tags
}

# module "resource_group_tooling" {
#   source            = "../../../../../modules/resource_group"
#   #name_override     = ""
#   application_name  = local.application_names.resource_group_tooling #var.application_name 
#   subscription_type = var.subscription_type                         # "conn"        
#   environment       = var.environment                               # "dev"                
#   location          = var.location                                  # "eastus"                
#   #instance_number   = var.instance_number                           # "001"            
#   tags              = var.tags
# }

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
# MANAGED IDENTITIES - AZURE POLICY
#------------------------------

# Managed Identity for Defender for Cloud Initiative - tbd Organization Azure Policy remediation
resource "azurerm_user_assigned_identity" "managed_identity_azpol_defender" {
  name                = "mi-azure-policy-defender-initiative-${var.location}"
  location            = var.location
  resource_group_name = module.resource_group_mgmt.name
  tags                = var.tags
}

# Managed Identity for Logging Initiative - tbd Organization Azure Policy remediation
resource "azurerm_user_assigned_identity" "managed_identity_azpol_logging" {
  name                = "mi-azure-policy-logging-initiative-${var.location}"
  location            = var.location
  resource_group_name = module.resource_group_mgmt.name
  tags                = var.tags
}

#------------------------------
# MANAGED IDENTITIES - AZURE AUTOMATION
#------------------------------

# Managed Identity for Logging Initiative - Cardinal Organization Azure Policy remediation
resource "azurerm_user_assigned_identity" "managed_identity_sandbox_cleanup" {
  name                = "mi-azure-automation-sandbox-cleanup-${var.location}"
  location            = var.location
  resource_group_name = module.resource_group_mgmt.name
  tags                = var.tags
}

#------------------------------
# MANAGED IDENTITIES - BACKUP VAULT 
#------------------------------

resource "azurerm_user_assigned_identity" "managed_identity_azpol_backup_vault_send_email" {
  name                = "mi-azure-policy-backup-${var.location}"
  location            = var.location
  resource_group_name = module.resource_group_mgmt.name
  tags                = var.tags
}

#------------------------------
# VIRTUAL NETWORKS
#------------------------------

module "virtual_network_mgmt" {
  source              = "../../../../../terraform_modules/network/virtual_network"
  #name_override       = ""
  application_name    = local.application_names.virtual_network_mgmt
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags 
  resource_group_name = module.resource_group_mgmt.name
  address_space       = var.management_vnet_address_space
}

#Diagnostic settings for the virtual network
module "virtual_network_mgmt_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.virtual_network_mgmt_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.virtual_network_mgmt.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

#------------------------------
# LOG ANALYTICS WORKSPACE
#------------------------------

module "log_analytics_workspace" {
  source              = "../../../../../terraform_modules/log_analytics_workspace"
  #name_override       = ""
  application_name    = local.application_names.log_analytics_workspace
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location 
  retention_in_days   = 180         
  #instance_number     = var.instance_number   
  tags                = var.tags
  resource_group_name = module.resource_group_mgmt.name
}

#This adds all the various logging solutions to the centralized LAW.  This will allow services like MS Defender for Cloud to export it's logs to this workspace.

resource "azurerm_log_analytics_solution" "solution" {
  for_each = local.solution_name
  solution_name         = each.key #"SecurityCenterFree"
  location              = var.location
  resource_group_name   = module.resource_group_mgmt.name
  workspace_resource_id = module.log_analytics_workspace.id
  workspace_name        = module.log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/${each.key}"
  }
}

#Diagnostic settings for the log analytics workspace
module "log_analytics_workspace_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = "ds-log-mgmt-dev-eastus-001"
  application_name            = local.application_names.log_analytics_workspace_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.log_analytics_workspace.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
  #depends_on                  = [ module.security_center ]
}

#------------------------------
# EVENT HUBS
#------------------------------

resource "azurerm_eventhub_namespace" "evhns_mgmt" {
  name                          = "evhns-shared-mgmt-${var.environment}-${var.location}"
  location                      = var.location
  resource_group_name           = module.resource_group_mgmt.name
  sku                           = "Standard"
  capacity                      = 1
  public_network_access_enabled = true
  zone_redundant                = true
  tags                          = var.tags

  network_rulesets {
    default_action                 = "Deny"
    trusted_service_access_enabled = true
    public_network_access_enabled = true
    ip_rule = [
      {
        ip_mask = "205.173.104.0/21"
        action  = "Allow"
  }
    ]
}
}

resource "azurerm_eventhub" "evh_mgmt" {
  name                = "evh-shared-mgmt-${var.environment}-${var.location}"
  namespace_name      = azurerm_eventhub_namespace.evhns_mgmt.name
  resource_group_name = module.resource_group_mgmt.name
  partition_count     = 2
  message_retention   = 7
}

module "mgmt_eventhub_namespace_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.mgmt_eventhub_namespace_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = azurerm_eventhub_namespace.evhns_mgmt.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

#------------------------------
# BACKUP VAULT
#------------------------------

resource "azurerm_data_protection_backup_vault" "mgmt_backup_vault" {
  name                = "bvault-shared-mgmt-${var.location}"
  resource_group_name = module.resource_group_mgmt.name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  tags                = var.tags
}

#Diagnostic settings for the backup vault
module "mgmt_backup_vault_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.mgmt_backup_vault_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = azurerm_data_protection_backup_vault.mgmt_backup_vault.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

#------------------------------
# RECOVERY SERVICES VAULT
#------------------------------

module "recovery_services_vault_mgmt" {
  source                                   = "../../../../../terraform_modules/recovery_services_vault"
  recovery_services_vault_name             = "rsv-shared-${var.subscription_type}-${var.environment}-${var.location}"
  location                                 = var.location
  rsv_resource_group_name                  = module.resource_group_mgmt.name
  vault_sku                                = "Standard"
  storage_mode_type                        = "ZoneRedundant"
  rsv_public_network_access_enabled        = true
  tags                                     = var.tags
}

#Diagnostic settings for the backup vault
module "mgmt_rsv_vault_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.mgmt_rsv_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.recovery_services_vault_mgmt.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

#------------------------------
# RSV VM BACKUP POLICY
#------------------------------

module "rsv_backup_policy_vm" {
  source                                  = "../../../../../terraform_modules/backup_policy_vm"
  backup_policy_name                      = "bkpol-vm-${var.subscription_type}-${var.environment}-${var.location}"
  bp_resource_group_name                  = module.resource_group_mgmt.name
  recovery_vault_name                     = module.recovery_services_vault_mgmt.name
  backup_policy_type                      = "V2"
  backup_policy_time_zone                 = "UTC"
  backup_policy_frequency                 = "Daily"
  backup_policy_time                      = "22:00"
  backup_policy_retention_daily_count     = 15
  backup_policy_retention_weekly_count    = 10
  backup_policy_retention_weekly_weekdays = ["Sunday"]
  backup_policy_retention_monthly_count    = 2
  backup_policy_retention_monthly_weekdays = ["Sunday"]
}

#------------------------------
# AZURE AUTOMATION ACCOUNTS
#------------------------------

# This is the primary automation account for the Landing Zone
resource "azurerm_automation_account" "aa_shared" {
  name                = "aa-shared-mgmt-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = module.resource_group_mgmt.name
  sku_name            = "Basic"
  tags = var.tags
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity_sandbox_cleanup.id]
  }
  depends_on = [ azurerm_user_assigned_identity.managed_identity_sandbox_cleanup ]
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
  resource_group_name   = module.resource_group_mgmt.name
  virtual_network_name  = module.virtual_network_mgmt.name
  address_prefixes      = var.kvmgmt_subnet_address_prefixes
  #address_prefixes      = ["72.20.99.0/28"] 
  service_endpoints     = [ "Microsoft.KeyVault" ]
  depends_on            = [ module.virtual_network_mgmt ]
}

#NSG for the Key Vault subnet
module "kvmgmt_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.kvmgmt_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_mgmt.name
}

#Diagnostic settings for the Key Vault
module "kvmgmt_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.kvmgmt_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.kvmgmt_subnet_network_security_group.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "kvmgmt_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_mgmt.name
  network_security_group_name   = module.kvmgmt_subnet_network_security_group.name
  network_security_group_rules  = var.kvmgmt_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
#Associates the NSG with the Key Vault subnet
resource "azurerm_subnet_network_security_group_association" "kvmgmt_network_security_group_association" {
  subnet_id                 = module.kv_subnet.id
  network_security_group_id = module.kvmgmt_subnet_network_security_group.id
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
  name                = "pe-kv-mgmt-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_key_vault.name
  location            = var.location
  subnet_id           = module.kv_subnet.id

  private_service_connection {
    name                           = "mgmt-privateserviceconnection"
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
  log_analytics_workspace_id  = module.log_analytics_workspace.id
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
  name                  = "keyvault_mgmt_vnet_link"
  resource_group_name   = module.resource_group_key_vault.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns_zone.name
  virtual_network_id    = module.virtual_network_mgmt.id
}

#------------------------------
# STORAGE ACCOUNT - TERRAFORM STATE
#------------------------------

#Initial storage account resources for the Terraform State file
module "tfstate_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.tfstate_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_mgmt.name
  virtual_network_name  = module.virtual_network_mgmt.name
  address_prefixes      = var.tfstate_subnet_address_prefixes
  #address_prefixes      = ["172.20.99.16/28"]
  service_endpoints     = [ "Microsoft.Storage" ]
  depends_on            = [ module.virtual_network_mgmt ]
}

#NSG for the tfstate subnet
module "tfstate_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.tfstate_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_mgmt.name
}

#Diagnostic settings for the tfstate subnet
module "tfstate_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.tfstate_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.tfstate_subnet_network_security_group.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "tfstate_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_mgmt.name
  network_security_group_name   = module.tfstate_subnet_network_security_group.name
  network_security_group_rules  = var.tfstate_subnet_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
#Associates the NSG with the tfstate storage account
resource "azurerm_subnet_network_security_group_association" "tfstate_network_security_group_association" {
  subnet_id                 = module.tfstate_subnet.id
  network_security_group_id = module.tfstate_subnet_network_security_group.id
}

module "storage_account_tfstate" {
  source              = "../../../../../terraform_modules/storage_account"       
  #name_override            = "stsharedmgmtdev001XX"   # NOTE: XX = 2 random hex characters, storage accounts can only be 24 characters max
  application_name          = local.application_names.storage_account_tfstate
  subscription_type         = var.subscription_type       
  environment               = var.environment              
  location                  = var.location          
  #instance_number          = var.instance_number   
  resource_group_name       = module.resource_group_mgmt.name
  #shared_access_key_enabled = false
  #infrastructure_encryption_enabled = true  #Enable when deploying Production hardened Landing Zone
  tags                      = var.tags
}

# TODO: this resource call needs to be turned into a module
# Create storage account Private Endpoint
resource "azurerm_private_endpoint" "tf_st_pe" {
  name                = "pe-tfst-mgmt-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_mgmt.name
  location            = var.location
  subnet_id           = module.tfstate_subnet.id

  private_service_connection {
    name                           = "tfst-privateserviceconnection"
    private_connection_resource_id = module.storage_account_tfstate.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "tfst-dns_zone"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_storage_dns_zone.id]
  }
  depends_on = [time_sleep.wait_30_seconds]
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_storage_account_network_rules" "tfstate_rules" {
  storage_account_id = module.storage_account_tfstate.id

  default_action             = "Deny"
  ip_rules                   = ["74.202.103.18"] 
  virtual_network_subnet_ids = [module.tfstate_subnet.id,module.ado_pipeline_agents_subnet.id]
  bypass                     = ["AzureServices"]
  private_link_access {
    endpoint_resource_id = azurerm_data_protection_backup_vault.mgmt_backup_vault.id
  }
  depends_on = [
    #azurerm_storage_container.statecontainer,
    azurerm_data_protection_backup_vault.mgmt_backup_vault,
    time_sleep.wait_30_seconds
    ]
}
#------------------------------
# STORAGE ACCOUNT - NSG FLOW LOGS
#------------------------------

module "nsgflow_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.nsgflow_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_mgmt.name
  virtual_network_name  = module.virtual_network_mgmt.name
  address_prefixes      = var.nsgflow_subnet_address_prefixes
  #address_prefixes      = ["172.20.99.32/28"] 
  service_endpoints     = [ "Microsoft.Storage" ]
  depends_on            = [ module.virtual_network_mgmt ]
}

module "nsgflow_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.nsgflow_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_mgmt.name
}

module "nsgflow_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.nsgflow_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.nsgflow_subnet_network_security_group.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "nsgflow_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_mgmt.name
  network_security_group_name   = module.nsgflow_subnet_network_security_group.name
  network_security_group_rules  = var.nsgflow_subnet_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "nsgflow_network_security_group_association" {
  subnet_id                 = module.nsgflow_subnet.id
  network_security_group_id = module.nsgflow_subnet_network_security_group.id
}

module "storage_account_nsgflow" {
  source              = "../../../../../terraform_modules/storage_account"       
  #name_override            = "stsharedmgmtdev001XX"   # NOTE: XX = 2 random hex characters, storage accounts can only be 24 characters max
  application_name          = local.application_names.storage_account_nsgflow
  subscription_type         = var.subscription_type       
  environment               = var.environment              
  location                  = var.location         
  #instance_number          = var.instance_number   
  resource_group_name       = module.resource_group_mgmt.name
  #shared_access_key_enabled = false
  #infrastructure_encryption_enabled = true   #Enable when deploying Production hardened Landing Zone
  tags                      = var.tags
}

# TODO: this resource call needs to be turned into a module
# Create storage account Private Endpoint
resource "azurerm_private_endpoint" "nsgflow_st_pe" {
  name                = "pe-nsgflow-mgmt-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_mgmt.name
  location            = var.location
  subnet_id           = module.nsgflow_subnet.id

  private_service_connection {
    name                           = "nsgflow-privateserviceconnection"
    private_connection_resource_id = module.storage_account_nsgflow.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "nsgflow-dns_zone"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_storage_dns_zone.id]
  }
  depends_on = [time_sleep.wait_30_seconds]
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_storage_account_network_rules" "nsgflow_rules" {
  storage_account_id = module.storage_account_nsgflow.id

  default_action             = "Deny"
  ip_rules                   = ["74.202.103.18"] 
  virtual_network_subnet_ids = [module.nsgflow_subnet.id]
  bypass                     = ["AzureServices"]
    private_link_access {
    endpoint_resource_id = azurerm_data_protection_backup_vault.mgmt_backup_vault.id
  }
  depends_on = [azurerm_data_protection_backup_vault.mgmt_backup_vault]
}

#------------------------------
# ADO PIPELINE CI/CD AGENTS 
#------------------------------

module "ado_pipeline_agents_subnet" {
  #count                 = var.enable_keyvault == true ? 1 : 0
  source                = "../../../../../terraform_modules/network/subnet"
  #name_override         = ""
  application_name      = local.application_names.ado_pipeline_agents_subnet
  subscription_type     = var.subscription_type       
  environment           = var.environment              
  location              = var.location          
  #instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_mgmt.name
  virtual_network_name  = module.virtual_network_mgmt.name
  address_prefixes      = var.ado_pipeline_agents_subnet_address_prefixes
  #address_prefixes      = ["172.20.99.16/28"]
  service_endpoints     = [ "Microsoft.Storage" ]
  depends_on            = [ module.virtual_network_mgmt ]
}

#NSG for the ado pipeline agents subnet
module "ado_pipeline_agents_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = ""
  application_name    = local.application_names.ado_pipeline_agents_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_mgmt.name
}

#Diagnostic settings for the ado pipeline agents nsg
module "ado_pipeline_agents_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = ""
  application_name            = local.application_names.ado_pipeline_agents_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type      
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.ado_pipeline_agents_subnet_network_security_group.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "ado_pipeline_agents_subnet_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_mgmt.name
  network_security_group_name   = module.ado_pipeline_agents_subnet_network_security_group.name
  network_security_group_rules  = var.ado_pipeline_agents_subnet_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
#Associates the NSG with the ado pipeline agents subnet
resource "azurerm_subnet_network_security_group_association" "ado_pipeline_agents_subnet_network_security_group_association" {
  subnet_id                 = module.ado_pipeline_agents_subnet.id
  network_security_group_id = module.ado_pipeline_agents_subnet_network_security_group.id
}

#----------------------------------------
# ADO SELF HOSTED AGENT VIRTUAL MACHINES
#----------------------------------------

#NOTE: This code block has been commented out due to the self hosted agent being deployed manually with a non-azure edition image.

# module "core_lz_pipeline_agent_vms" {
#   source                        = "../../../../../terraform_modules/lz_pipeline_agent_vm/v2"
#   for_each                      = var.ado_virtual_machines
#   location                      = var.location
#   resource_group_name           = module.resource_group_mgmt.name
#   subnet_id                     = module.ado_pipeline_agents_subnet.id
#   key_vault_id                  = module.key_vault.id
#   vm_name                       = each.key
#   size                          = each.value.size
#   private_ip_address_allocation = each.value.private_ip_address_allocation
#   #zone                          = null
#   #cache                         = each.value.cache
#   storage_account_type          = each.value.storage_account_type
#   tags                          = var.tags
# }

#------------------------------
# BLOB STORAGE DNS ZONE
#------------------------------


################################## Blob Storage DNS zone #####################################
resource "azurerm_private_dns_zone" "blob_storage_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_group_mgmt.name
}

#------------------------------
# AZURE BASTION
#------------------------------

module "bastion_subnet" {
  source                = "../../../../../terraform_modules/network/subnet"
  name_override         = local.application_names.bastion_subnet   # NOTE: Bastion MUST use this name for the Bastion Subnet, and the subnet mask must be at least a '/26'.
  # application_name      = "bas"
  # subscription_type     = var.subscription_type       
  # environment           = var.environment              
  # location              = var.location          
  # instance_number       = var.instance_number  
  resource_group_name   = module.resource_group_mgmt.name
  virtual_network_name  = module.virtual_network_mgmt.name
  address_prefixes      = var.bastion_subnet_address_prefixes
}

module "bastion_subnet_network_security_group" {
  source              = "../../../../../terraform_modules/network/network_security_group"
  #name_override       = "nsg-bas-conn-dev-eastus-001"
  application_name    = local.application_names.bastion_subnet_network_security_group
  subscription_type   = var.subscription_type       
  environment         = var.environment              
  location            = var.location          
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_mgmt.name
}

module "bastion_subnet_nsg_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = "ds-bas_nsg-conn-dev-eastus-001"
  application_name            = local.application_names.bastion_subnet_nsg_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.bastion_subnet_network_security_group.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "bastion_network_security_group_rules" {
  source                        = "../../../../../terraform_modules/network/network_security_rule"
  resource_group_name           = module.resource_group_mgmt.name
  network_security_group_name   = module.bastion_subnet_network_security_group.name
  network_security_group_rules  = var.bastion_subnet_network_security_group_rules
}

# TODO: this resource call needs to be turned into a module
resource "azurerm_subnet_network_security_group_association" "bastion_network_security_group_association" {
  subnet_id                 = module.bastion_subnet.id
  network_security_group_id = module.bastion_subnet_network_security_group.id
}

# # TODO: need to determine what the sku and allocation_method need to be for Bastion Public IPs
module "public_ip_bastion" {
  source              = "../../../../../terraform_modules/network/public_ip"
  #name_override       = "pip-bas-conn-dev-eastus-001"
  application_name    = local.application_names.public_ip_bastion               
  subscription_type   = var.subscription_type
  environment         = var.environment      
  location            = var.location         
  #instance_number     = var.instance_number  
  tags                = var.tags
  resource_group_name = module.resource_group_mgmt.name
  allocation_method   = "Static"
  sku                 = "Standard"
  #zones              = var.zones
}

module "public_ip_bastion_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = "ds-pip_bas-conn-dev-eastus-001"
  application_name            = local.application_names.public_ip_bastion_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.public_ip_bastion.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

module "bastion_host" {
  source                                = "../../../../../terraform_modules/bastion_host"
  #name_override                         = "bas-host-conn-dev-eastus-001"
  application_name                      = local.application_names.bastion_host
  subscription_type                     = var.subscription_type       
  environment                           = var.environment              
  location                              = var.location
  sku                                   = "Standard"          
  #instance_number                       = var.instance_number  
  tags                                  = var.tags 
  resource_group_name                   = module.resource_group_mgmt.name
  #ip_configuration_name_override        = "ipconf-bas-host-conn-dev-eastus-001"
  ip_configuration_subnet_id            = module.bastion_subnet.id
  ip_configuration_public_ip_address_id = module.public_ip_bastion.id
  depends_on                            = [ 
    module.virtual_network_mgmt, 
    module.bastion_subnet 
  ]
}

module "bastion_host_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = "ds-bas_host-conn-dev-eastus-001"
  application_name            = local.application_names.bastion_host_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = module.bastion_host.id
  log_analytics_workspace_id  = module.log_analytics_workspace.id
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
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
  depends_on          = [ module.virtual_network_mgmt ]
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
  storage_account_id        = module.storage_account_nsgflow.id #var.nsg_flow_log_storage_account_id
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
      workspace_id          = module.log_analytics_workspace.workspace_id
      workspace_region      = module.log_analytics_workspace.location
      workspace_resource_id = module.log_analytics_workspace.id
    }
  }
  depends_on = [
    module.virtual_network_mgmt,
    module.kvmgmt_subnet_network_security_group,
    module.tfstate_subnet_network_security_group,
    module.nsgflow_subnet_network_security_group,
    module.bastion_subnet_network_security_group
  ]
}

#------------------------------
# ACTION GROUPS
#------------------------------

# # TODO: Replace this resource call with a module
resource "azurerm_monitor_action_group" "cloudops_action_group" {
  name                = "ag-cloudops" #"${var.subscription_type}_action_group"
  resource_group_name = module.resource_group_mgmt.name
  short_name          = "cloudops" #"${var.subscription_type}"
  tags              = var.tags
  email_receiver {
    name                    = "sendtocloudops"
    email_address           = var.cloudops_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_action_group" "infosec_action_group" {
  name                = "ag-infosec" #"${var.subscription_type}_action_group"
  resource_group_name = module.resource_group_mgmt.name
  short_name          = "infosec" #"${var.subscription_type}"
  tags              = var.tags
  email_receiver {
    name                    = "sendtoinfosec"
    email_address           = var.infosec_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_action_group" "cloudbudget_action_group" {
  name                = "ag-cloudbudget" #"${var.subscription_type}_action_group"
  resource_group_name = module.resource_group_mgmt.name
  short_name          = "cloudbudget" #"${var.subscription_type}"
  tags              = var.tags
  email_receiver {
    name                    = "sendtocloudbudget"
    email_address           = var.cloudbudget_email
    use_common_alert_schema = true
  }
}

#------------------------------
# ALERTS
#------------------------------

# TODO: Bring this module up to par with the standards in other modules
module "management_activity_log_alert" {
  source                              = "../../../../../terraform_modules/monitor_activity_log_alert"
  log_alert_name                      = var.log_alert_name
  resource_group_name                 = module.resource_group_mgmt.name
  log_alert_scopes                    = [data.azurerm_subscription.current.id]
  log_alert_description               = "This activity log alert is to monitor the health of all services in the ${var.subscription_type} subsciption"
  log_alert_enabled                   = true
  criteria_category                   = "ServiceHealth"
  service_health_locations            = [var.location]
  action_group_id                     = azurerm_monitor_action_group.cloudops_action_group.id
  tags                                = var.tags
}
