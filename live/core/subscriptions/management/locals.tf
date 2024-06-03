#------------------------------
# LOCALS
#------------------------------

locals {
  application_names = {
    resource_group_mgmt                         = "shared"
    resource_group_tooling                      = "tooling"
    resource_group_alert_rules                  = "alert_rules"
    virtual_network_mgmt                        = "shared"
    virtual_network_mgmt_diagnostic_settings    = "vnet_shared"
    log_analytics_workspace                     = "shared"
    log_analytics_workspace_diagnostic_settings = "log"
    mgmt_eventhub_namespace_diagnostic_settings = "evhns"
    resource_group_key_vault                    = "kv"
    key_vault                                   = "shared"
    key_vault_diagnostic_settings               = "kv"
    kv_subnet                                   = "kv"
    kvmgmt_subnet_network_security_group        = "kv"
    kvmgmt_subnet_nsg_diagnostic_settings       = "kvmgmt_nsg"
    # # resource_group_storage_account              = "st"
    storage_account_tfstate                     = "tfstate"
    # storage_diagnostic_tfstate_settings         = "st"
    tfstate_subnet                              = "tfstate"
    tfstate_subnet_network_security_group       = "tfstate"
    tfstate_subnet_nsg_diagnostic_settings      = "tfstate_nsg" 
    storage_account_nsgflow                     = "nsgflow"
    # storage_diagnostic_nsgflow_settings         = "st"
    nsgflow_subnet                              = "nsgflow"
    nsgflow_subnet_network_security_group       = "nsgflow"
    nsgflow_subnet_nsg_diagnostic_settings      = "nsgflow_nsg"
    # storage_account_vmbackup                    = "vmbackup"
    ado_pipeline_agents_subnet                  = "pipeline_agents"
    ado_pipeline_agents_subnet_network_security_group  = "pipeline_agents"
    ado_pipeline_agents_subnet_nsg_diagnostic_settings = "pipeline_agents_nsg"
    mgmt_backup_vault_diagnostic_settings       = "bvault_shared"
    mgmt_rsv_diagnostic_settings                = "rsv_shared"
    bastion_subnet                              = "AzureBastionSubnet"
    bastion_subnet_network_security_group       = "bastion"
    bastion_subnet_nsg_diagnostic_settings      = "bastion_nsg"
    public_ip_bastion                           = "bas"
    public_ip_bastion_diagnostic_settings       = "pip_bas"
    bastion_host                                = "host"
    bastion_host_diagnostic_settings            = "bas_host" 
    # jumpbox_virtual_machine                     = "jumpbox"
    # pipeline_agent_virtual_machine              = "pipeline_agent_01"
    # TODO: add local application_names for remaining resource calls once they are module calls
  }
  diagnostic_settings = {
    logs_to_exclude     = []
    metrics_to_exclude  = []
    retention_days      = "7"
  }
  network_security_groups = {
    kv              = module.kvmgmt_subnet_network_security_group.id
    tfstate         = module.tfstate_subnet_network_security_group.id
    nsgflow         = module.nsgflow_subnet_network_security_group.id
    pipeline_agents = module.ado_pipeline_agents_subnet_network_security_group.id
    bastion         = module.bastion_subnet_network_security_group.id
  }
  solution_name = toset([
    "Security","SecurityInsights","AgentHealthAssessment","AzureActivity","SecurityCenterFree","DnsAnalytics","ADAssessment","AntiMalware","ServiceMap","SQLAssessment", "SQLAdvancedThreatProtection", "AzureAutomation", "Containers", "ChangeTracking", "Updates", "VMInsights",
  ])
}