#------------------------------
# DEFENDER FOR CLOUD
#------------------------------

resource "azurerm_security_center_contact" "defender_default_contact" {
  email = var.infosec_email

  alert_notifications = true
  alerts_to_admins    = true
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

module "resource_group_vwan" {
  source            = "../../../../../terraform_modules/resource_group"
  #name_override     = "rg-shared-conn-dev-eastus-001"
  application_name  = local.application_names.resource_group_vwan #var.application_name 
  subscription_type = var.subscription_type                         # "conn"        
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
# KEY VAULT
#------------------------------

#------------------------------
# LOG ANALYTICS WORKSPACE
#------------------------------

#------------------------------
# ALERTS
#------------------------------

#------------------------------
# VWAN
#------------------------------

# TODO: these resource calls needs to be turned into modules

# Virtual WAN
resource "azurerm_virtual_wan" "vwan" {
  name                = "vwan-shared-conn-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_vwan.name
  location            = var.location
  tags                = var.tags 
}

#------------------------------
# VWAN HUB
#------------------------------

# TODO: these resource calls needs to be turned into modules

resource "azurerm_virtual_hub" "vwhub" {
  name                = "vwhub-shared-conn-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_vwan.name
  sku                 = "Standard"
  location            = var.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = var.vwhub_address_prefix
  #address_prefix      = "172.20.250.0/23"
  hub_routing_preference = "ASPath"
  # route {
  #   address_prefixes = ["10.0.0.0/8"]
  #   next_hop_ip_address = "172.20.254.4"
  # }
  tags                = var.tags 
}

resource "azurerm_virtual_hub_routing_intent" "hubRoutingIntent" {
  name           = "hubRoutingIntent"
  virtual_hub_id = azurerm_virtual_hub.vwhub.id

routing_policy {  #This policy forces Private traffic to send via Azure Firewall
  name         = "PrivateTrafficPolicy"
  destinations = ["PrivateTraffic"]
  next_hop     = azurerm_firewall.fw01.id
}

routing_policy {  #This policy forces Internet traffic through the Azure Firewall.
  name           = "InternetTrafficPolicy"
  destinations   = ["Internet"]
  next_hop       = azurerm_firewall.fw01.id
}

  depends_on                = [ azurerm_firewall.fw01 ]
}

#------------------------------
# VWHUB FIREWALL
#------------------------------

# TODO: these resource calls needs to be turned into modules

# Firewall
resource "azurerm_firewall" "fw01" {
    name                = "afw-shared-conn-${var.environment}-${var.location}" 
    location            = var.location
    resource_group_name = module.resource_group_vwan.name
    sku_tier            = "Premium"
    sku_name            = "AZFW_Hub"
    firewall_policy_id  = azurerm_firewall_policy.fw-pol01.id
    tags              = var.tags
    virtual_hub {
      virtual_hub_id = azurerm_virtual_hub.vwhub.id
      public_ip_count = 1
  }
  depends_on                            = [ 
    azurerm_firewall_policy.fw-pol01,
    azurerm_firewall_policy_rule_collection_group.fw01-policy1,
  ]
}
# Firewall Policy
resource "azurerm_firewall_policy" "fw-pol01" {
  name                = "afw-shared-conn-defaultpol01" 
  resource_group_name = module.resource_group_vwan.name
  sku                 = "Premium"
  location            = var.location
  threat_intelligence_mode = "Deny"  #Set this to "Deny" for the production Landing Zone
  tags                = var.tags
  dns {
    proxy_enabled = true
    servers        = var.connectivity_vwhub_firewall_dns_servers
    #servers       = ["172.20.1.20"]
  }
  intrusion_detection {
    mode = "Deny"  #Set this to "Deny" for the production Landing Zone
  }
}

# Firewall Policy Rules
resource "azurerm_firewall_policy_rule_collection_group" "fw01-policy1" {
  name               = "afw-shared-conn-defaultpol01-rules" 
  firewall_policy_id = azurerm_firewall_policy.fw-pol01.id
  priority           = 100
  network_rule_collection {
    name     = "network_rules1"
    priority = 100
    action   = "Allow"
    # rule {            #THIS RULE IS FOR INITIAL TESTING PURPOSES ONLY
    #   name                  = "network_rule_collection1_rule1"
    #   protocols             = ["TCP", "UDP", "ICMP"]
    #   source_addresses      = ["*"]
    #   destination_addresses = ["*"]
    #   destination_ports     = ["*"]
    # }
    rule {
      name                  = "AllowRDP"
      protocols             = ["TCP","UDP"]
      source_addresses      = ["10.0.0.0/8","10.220.0.0/23"]
      destination_addresses = ["10.220.2.0/24","10.220.3.0/24","10.220.4.0/22","10.220.8.0/22","10.220.12.0/22", "10.220.16.0/22", "10.220.20.0/22"]
      destination_ports     = ["3389"]
    }
    rule {
      name                  = "AllowHTTPS"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/8","10.220.0.0/23"]
      destination_addresses = ["10.220.2.0/24","10.220.3.0/24","10.220.4.0/22","10.220.8.0/22","10.220.12.0/22", "10.220.16.0/22", "10.220.20.0/22"]
      destination_ports     = ["443"]
    } 
    rule {
      name                  = "AllowReverseHTTPS"
      protocols             = ["TCP"]
      source_addresses      = ["10.220.2.0/24","10.220.3.0/24","10.220.4.0/22","10.220.8.0/22","10.220.12.0/22", "10.220.16.0/22", "10.220.20.0/22"]
      destination_addresses = ["10.0.0.0/8","10.220.0.0/23"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "AllowDNS"
      protocols             = ["TCP","UDP"]
      source_addresses      = ["10.0.0.0/8","10.220.0.0/23"]
      destination_addresses = ["10.220.2.0/24","10.220.3.0/24","10.220.4.0/22","10.220.8.0/22","10.220.12.0/22", "10.220.16.0/22", "10.220.20.0/22"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "AllowReverseDNS"
      protocols             = ["TCP","UDP"]
      source_addresses      = ["10.220.2.0/24","10.220.3.0/24","10.220.4.0/22","10.220.8.0/22","10.220.12.0/22", "10.220.16.0/22", "10.220.20.0/22"]
      destination_addresses = ["10.0.0.0/8","10.220.0.0/23"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "AllowADO"
      protocols             = ["TCP","UDP"]
      source_addresses      = ["10.220.2.32/28"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "AllowWindowsKMS"
      protocols             = ["TCP","UDP"]
      source_addresses      = ["10.220.2.0/24","10.220.3.0/24","10.220.4.0/22","10.220.8.0/22","10.220.12.0/22", "10.220.16.0/22", "10.220.20.0/22"]
      destination_addresses = ["*"]
      destination_ports     = ["1688"]
    }
  }
  application_rule_collection {
    name     = "app_rule_collection1"
    priority = 101
    action   = "Allow"
    rule {
      name = "app_rule_collection1_rule1"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dev.azure.com", "*dev.azure.com", "*.dev.azure.com", "*.vsblob.visualstudio.com", "*.vssps.visualstudio.com", "*.vstmr.visualstudio.com","app.vssps.visualstudio.com", "*.blob.core.windows.net", "management.core.windows.net", "azkms.core.windows.net", "kms.core.windows.net", "login.microsoftonline.com", "vstsagentpackage.azureedge.net", "*.microsoft.com", "ntp.msn.com", "*.azureedge.net", "*.azure-automation.net", "*.azure.com", "login.live.com", "aka.ms", "azcliprod.blob.core.windows.net", "*.hashicorp.com", "*.terraform.io", "cacerts.digicert.com", "cacerts.digicert.cn", "cacerts.geotrust.com", "crl3.digicert.com", "crl4.digicert.com", "crl.digicert.cn", "cdp.geotrust.com", "oscp.msocsp.com", "ocsp.digicert.com", "ocsp.digicert.cn", "status.geotrust.com"]
    }
  }
  application_rule_collection {
    name     = "app_rule_collection_vms"
    priority = 102
    action   = "Allow"
    rule {
      name = "app_rule_collection_vms_rule_win_updates_https"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdn_tags = ["WindowsUpdate"]
    }
  }
  depends_on                = [ azurerm_firewall_policy.fw-pol01 ]
}

module "firewall_diagnostic_settings" {
  source                      = "../../../../../terraform_modules/diagnostic_settings"
  #name_override               = "ds-afw-conn-dev-eastus-001"
  application_name            = local.application_names.firewall_diagnostic_settings
  subscription_type           = var.subscription_type       
  environment                 = var.environment              
  location                    = var.location          
  #instance_number             = var.instance_number   
  resource_id                 = azurerm_firewall.fw01.id
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  log_analytics_destination_type = "AzureDiagnostics"
  logs_to_exclude             = local.diagnostic_settings.logs_to_exclude
  metrics_to_exclude          = local.diagnostic_settings.metrics_to_exclude
  retention_days              = local.diagnostic_settings.retention_days
}

#------------------------------
# VWHUB VPN GATEWAY
#------------------------------

resource "azurerm_vpn_gateway" "gw01" {
  name                = "vpng-shared-conn-${var.environment}-${var.location}" 
  location            = var.location
  resource_group_name = module.resource_group_vwan.name
  virtual_hub_id      = azurerm_virtual_hub.vwhub.id
}

resource "azurerm_vpn_site" "tbd_onprem_atlanta" {
  name                = "vst-shared-conn-atlanta-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = module.resource_group_vwan.name
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_cidrs       = ["10.0.0.0/8"]
  device_vendor       = "Cisco"
  device_model        = "ASR1004"
  link {
    name          = "link1"
    provider_name = "AT&T"
    speed_in_mbps = "7000"
    ip_address = "12.89.135.206"
  }
  # link {
  #   name       = "link2"
  #   ip_address = "10.2.0.0"
  # }
}

resource "azurerm_vpn_gateway_connection" "conn-atlanta" {
  name               = "vcn-shared-conn-atlanta-${var.environment}-${var.location}"
  vpn_gateway_id     = azurerm_vpn_gateway.gw01.id
  remote_vpn_site_id = azurerm_vpn_site.tbd_onprem_atlanta.id

  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.tbd_onprem_atlanta.link[0].id
  }

  # vpn_link {
  #   name             = "link2"
  #   vpn_site_link_id = azurerm_vpn_site.example.link[1].id
  # }
}

#------------------------------
# ALERTS
#------------------------------

# TODO: create module for this resource call and bring variables up to standard with the rest of the modules
resource "azurerm_monitor_action_group" "connectivity_action_group" {
  name                = "ag-${var.subscription_type}-${var.environment}-${var.location}"
  resource_group_name = module.resource_group_vwan.name
  short_name          = "${var.subscription_type}"
  email_receiver {
    name                    = "sendtocloudops"
    email_address           = var.cloudops_email
    use_common_alert_schema = true
  }
}

# TODO: update this module to be up to standard with the rest of the modules
module "connectivity_activity_log_alert" {
  source                    = "../../../../../terraform_modules/monitor_activity_log_alert"
  log_alert_name            = var.log_alert_name
  resource_group_name       = module.resource_group_vwan.name
  log_alert_scopes          = [data.azurerm_subscription.current.id]
  log_alert_description     = "This activity log alert is to monitor the health of all services in the ${var.subscription_type} subscription"
  log_alert_enabled         = true
  criteria_category         = "ServiceHealth"
  service_health_locations  = [var.location]
  #action_group_id           = azurerm_monitor_action_group.connectivity_action_group.id
  action_group_id            = var.cloudops_action_group_id
  tags                      = var.tags
}