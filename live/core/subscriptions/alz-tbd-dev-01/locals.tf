#------------------------------
# LOCALS
#------------------------------

locals {
  application_names = {
    resource_group_shared                          = "shared"
    resource_group_alert_rules                     = "alert_rules"
    virtual_network_tbddev01                      = "spoke"
    virtual_network_tbddev01_diagnostic_settings  = "vnet-tbddev01"
    apptbddev01_subnet                            = "app"
    apptbddev01_subnet_network_security_group     = "app"
    apptbddev01_subnet_nsg_diagnostic_settings    = "app"
    datatbddev01_subnet                           = "data"
    datatbddev01_subnet_network_security_group    = "data"
    datatbddev01_subnet_nsg_diagnostic_settings   = "data" 
    petbddev01_subnet                             = "pe"
    petbddev01_subnet_network_security_group      = "pe"
    petbddev01_subnet_nsg_diagnostic_settings     = "pe"    
    log_analytics_workspace                        = "shared"
    log_analytics_workspace_diagnostic_settings    = "log"
    resource_group_key_vault                       = "kv"
    key_vault                                      = "shared"
    key_vault_diagnostic_settings                  = "kv"
    kvtbddev01_subnet                             = "kv"
    kvtbddev01_subnet_network_security_group      = "kv"
    kvtbddev01_subnet_nsg_diagnostic_settings     = "kvtbddev01_nsg"
    # TODO: add local application_names for remaining resource calls once they are module calls
  }
  diagnostic_settings = {
    logs_to_exclude     = []
    metrics_to_exclude  = []
    retention_days      = "7"
  }
  network_security_groups = {
    # kv              = module.kvmgmt_subnet_network_security_group.id
    app          = module.apptbddev01_subnet_network_security_group.id
    data         = module.datatbddev01_subnet_network_security_group.id
    pe           = module.petbddev01_subnet_network_security_group.id
    kv           = module.kvtbddev01_subnet_network_security_group.id
  }
  solution_name = toset([
    "Security","SecurityInsights","AgentHealthAssessment","AzureActivity","SecurityCenterFree","DnsAnalytics","ADAssessment","AntiMalware","ServiceMap","SQLAssessment", "SQLAdvancedThreatProtection", "AzureAutomation", "Containers", "ChangeTracking", "Updates", "VMInsights",
  ])
}