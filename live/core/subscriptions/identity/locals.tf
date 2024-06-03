#------------------------------
# LOCALS
#------------------------------

locals {
  application_names = {
    resource_group_identity                     = "shared"
    resource_group_alert_rules                  = "alert_rules"
    virtual_network_identity                    = "shared"
    virtual_network_identity_diagnostic_settings  = "vnet_id"
    resource_group_key_vault                    = "kv"
    key_vault                                   = "identity"
    key_vault_diagnostic_settings               = "kv"
    kv_subnet                                   = "kv"
    kvid_subnet_network_security_group          = "kv"
    kvid_subnet_nsg_diagnostic_settings         = "kvid_nsg"
    addc_subnet                                 = "addc"
    addc_subnet_network_security_group          = "addc"
    addc_subnet_nsg_diagnostic_settings         = "addc_nsg"
    infoblox_subnet                             = "infoblox"
    infoblox_subnet_network_security_group      = "infoblox"
    infoblox_subnet_nsg_diagnostic_settings     = "infoblox_nsg"
    pr_subnet_inbound                           = "dnsprin"
    pr_subnet_outbound                          = "dnsprout"
    prinbound_subnet_network_security_group     = "dnsprin"
    prinbound_subnet_nsg_diagnostic_settings    = "dnsprin_nsg"
    proutbound_subnet_network_security_group    = "dnsprout"
    proutbound_subnet_nsg_diagnostic_settings   = "dnsprout_nsg"
    # jumpbox_virtual_machine                     = "jumpbox"
    # TODO: add local application_names for remaining resource calls once they are module calls
  }
  diagnostic_settings = {
    logs_to_exclude     = []
    metrics_to_exclude  = []
    retention_days      = "7"
  }
  network_security_groups = {
      kv   = module.kvid_subnet_network_security_group.id
      addc = module.addc_subnet_network_security_group.id
      infoblox = module.infoblox_subnet_network_security_group.id
      inbound  = module.prinbound_subnet_network_security_group.id
      outbound = module.proutbound_subnet_network_security_group.id
  }
}