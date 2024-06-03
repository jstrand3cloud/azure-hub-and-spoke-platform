#------------------------------
# RESOURCE CONVENTIONS
#------------------------------

# Application, Subscription, Location, Environment, and Instance Number
# NOTE: these values are used to create names for resources and resource groups (please be mindful of character length limits)
application_name    = "Landing Zone"
subscription_type   = "connectivity"
environment         = "core"
location            = "eastus2"
#instance_number     = "069"


#------------------------------
# TAGS
#------------------------------


tags = {
  project_name              = "landing zone core"
  department                = "infra"
  environment               = "prod"
  terraform                 = "managed"
  operations_contact        = "opsteamname - TBD@tbd.org"
  cost_center               = "11228"
  owner                     = "tbdo@tbd.org"
  #data_classification_type = "Public"
}

#------------------------------
# TOGGLES
#------------------------------

enable_connectivity_subscription  = true
enable_identity_subscription      = true
enable_management_subscription    = true
enable_tbddev01_subscription     = true

#------------------------------
# HIGH AVAILABILITY / FAILOVER
#------------------------------

# Availability Zones
zones = [ "1", "2", "3" ]

#------------------------------
# SECURITY CENTER / DEFENDER FOR CLOUD
#------------------------------

email = "tbd@tbd.org"

#------------------------------
# ACTION GROUPS
#------------------------------

#service_health_email: ""
cloudops_email    = "tbd@tbd.org"
infosec_email     = "tbd@tbd.org"
cloudbudget_email = "azurecorebudget@tbd.org"

#------------------------------
# VIRTUAL NETWORK / SUBNET ADDRESSES
#------------------------------

# Connectivity Subscription
vwhub_address_prefix                        = "172.16.0.0/23"

# Management Subscription
management_vnet_address_space               = ["172.16.2.0/24"]
kvmgmt_subnet_address_prefixes              = ["172.16.2.0/28"]
nsgflow_subnet_address_prefixes             = ["172.16.2.16/28"]
ado_pipeline_agents_subnet_address_prefixes = ["172.16.2.32/28"]
tfstate_subnet_address_prefixes             = ["172.16.2.48/28"]
bastion_subnet_address_prefixes             = ["172.16.2.64/26"]

# Identity Subscription
identity_vnet_address_space                 = ["172.16.3.0/24"]
kvid_subnet_address_prefixes                = ["172.16.3.0/28"]
addc_subnet_address_prefixes                = ["172.16.3.16/28"]
infoblox_subnet_address_prefixes            = ["172.16.3.32/28"]
pr_subnet_inbound_address_prefixes          = ["172.16.3.48/28"]
pr_subnet_outbound_address_prefixes         = ["172.16.3.64/28"] 

# tbddev01 Subscription
tbddev01_vnet_address_space                = ["172.16.4.0/22"]
apptbddev01_subnet_address_prefixes        = ["172.16.4.0/24"]
datatbddev01_subnet_address_prefixes       = ["172.16.5.0/24"]
petbddev01_subnet_address_prefixes         = ["172.16.6.0/28"]
kvtbddev01_subnet_address_prefixes         = ["172.16.6.16/28"]

#------------------------------
# FIREWALL DNS SERVERS
#------------------------------

connectivity_vwhub_firewall_dns_servers      = ["172.16.3.52"]

#----------------------------------------
# ADO SELF HOSTED AGENT VIRTUAL MACHINES
#----------------------------------------

ado_virtual_machines = {
  "vm-lzadoagent01" = {
    private_ip_address_allocation = "Dynamic"
    size                          = "Standard_B2S"
    #zone                          = 2
    #cache                         = "None"
    storage_account_type          = "Standard_LRS"
  }
}

#------------------------------
# NETWORK SECURITY GROUP / (NSG) RULES
#------------------------------

# Default Rules for all NSGs.  Only use once you are sure what rules you will allow before you apply these deny rules
default_network_security_group_rules = {
  rule11 = {
    name                         = "AllowAzureLoadBalancer"
    description                  = null
    priority                     = "199"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "*"
    destination_port_ranges      = null
    source_address_prefix        = "AzureLoadBalancer"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule12 = {
    name                         = "DenyAllInbound"
    description                  = null
    priority                     = "500"
    direction                    = "Inbound"
    access                       = "Deny"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "*"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule13 = {
    name                         = "DenyAllOutBound"
    description                  = null
    priority                     = "500"
    direction                    = "Outbound"
    access                       = "Deny"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "*"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule14 = {
    name                         = "AllowWindowsKMS"
    description                  = null
    priority                     = "200"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "1688"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

#------------------------------
# MANAGEMENT SUBSCRIPTION NSG RULES
#------------------------------

# Key Vault Subnet
kvmgmt_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# NSG Flow Logs Storage account Subnet

nsgflow_subnet_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# ADO Pipeline agent Subnet

ado_pipeline_agents_subnet_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule3 = {
    name                         = "AllDNSTCPOutBound"
    description                  = null
    priority                     = "101"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule4 = {
    name                         = "AllDNSTCPInBound"
    description                  = null
    priority                     = "101"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule5 = {
    name                         = "AllDNSUDPOutBound"
    description                  = null
    priority                     = "102"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule6 = {
    name                         = "AllDNSUDPInBound"
    description                  = null
    priority                     = "102"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule7 = {
    name                         = "AllRDPInBound"
    description                  = null
    priority                     = "103"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "3389"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# Terraform State Storage account Subnet

tfstate_subnet_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# Bastion Subnet

bastion_subnet_network_security_group_rules = {
  # Inbound
  rule1 = {
    name                         = "Allow_TCP_443_Internet"
    description                  = null
    priority                     = 100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = null
    destination_port_ranges      = ["443"]
    source_address_prefix        = "Internet"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "Allow_TCP_443_GatewayManager"
    description                  = null
    priority                     = 110
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = null
    destination_port_ranges      = ["443"]
    source_address_prefix        = "GatewayManager"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule3 = {
    name                         = "Allow_BastionHost_Communication"
    description                  = null
    priority                     = 130
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = null
    destination_port_ranges      = ["8080", "5701"]
    source_address_prefix        = "VirtualNetwork"
    source_address_prefixes      = null
    destination_address_prefix   = "VirtualNetwork"
    destination_address_prefixes = null
  }
  rule4 = {
    name                         = "Allow_TCP_443_AzureLoadBalancer"
    description                  = null
    priority                     = 140
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = null
    destination_port_ranges      = ["443"]
    source_address_prefix        = "AzureLoadBalancer"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule5 = {
    name                         = "Deny_any_other_traffic"
    description                  = null
    priority                     = 900
    direction                    = "Inbound"
    access                       = "Deny"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "*"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  # Outbound
  rule6 = {
    name                         = "Allow_TCP_3389_VirtualNetwork"
    description                  = null
    priority                     = 100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "3389"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "VirtualNetwork"
    destination_address_prefixes = null
  }
  rule7 = {
    name                         = "Allow_TCP_22_VirtualNetwork"
    description                  = null
    priority                     = 110
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "22"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "VirtualNetwork"
    destination_address_prefixes = null
  }
  rule8 = {
    name                         = "Allow_TCP_443_AzureCloud"
    description                  = null
    priority                     = 120
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "AzureCloud"
    destination_address_prefixes = null
  }
  rule9 = {
    name                         = "Allow_Bastion_Communication"
    description                  = null
    priority                     = 130
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = null
    destination_port_ranges      = ["8080", "5701"]
    source_address_prefix        = "VirtualNetwork"
    source_address_prefixes      = null
    destination_address_prefix   = "VirtualNetwork"
    destination_address_prefixes = null
  }
  rule10 = {
    name                         = "Allow_GetSession_information"
    description                  = null
    priority                     = 140
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "80"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "Internet"
    destination_address_prefixes = null
  }
}

#------------------------------
# IDENTITY SUBSCRIPTION NSG RULES
#------------------------------

# Key Vault Subnet 
kvid_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# Active Directory Domain Controller Subnet 
addc_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule3 = {
    name                         = "AllDNSTCPOutBound"
    description                  = null
    priority                     = "101"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule4 = {
    name                         = "AllDNSTCPInBound"
    description                  = null
    priority                     = "101"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule5 = {
    name                         = "AllDNSUDPOutBound"
    description                  = null
    priority                     = "102"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule6 = {
    name                         = "AllDNSUDPInBound"
    description                  = null
    priority                     = "102"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule7 = {
    name                         = "AllRDPInBound"
    description                  = null
    priority                     = "103"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "3389"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# Infoblox Subnet 
infoblox_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule3 = {
    name                         = "AllDNSTCPOutBound"
    description                  = null
    priority                     = "101"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule4 = {
    name                         = "AllDNSTCPInBound"
    description                  = null
    priority                     = "101"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule5 = {
    name                         = "AllDNSUDPOutBound"
    description                  = null
    priority                     = "102"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule6 = {
    name                         = "AllDNSUDPInBound"
    description                  = null
    priority                     = "102"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule7 = {
    name                         = "AllRDPInBound"
    description                  = null
    priority                     = "103"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "3389"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# DNS Private Resolver subnets 
dnspr_network_security_group_rules = {
rule1 = {
    name                         = "AllDNSTCPOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllDNSTCPInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule3 = {
    name                         = "AllDNSUDPOutBound"
    description                  = null
    priority                     = "101"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule4 = {
    name                         = "AllDNSUDPInBound"
    description                  = null
    priority                     = "101"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

#------------------------------
# tbddev01 SUBSCRIPTION NSG RULES
#------------------------------

# Application subnet
apptbddev01_subnet_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule3 = {
    name                         = "AllDNSTCPOutBound"
    description                  = null
    priority                     = "101"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule4 = {
    name                         = "AllDNSTCPInBound"
    description                  = null
    priority                     = "101"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
rule5 = {
    name                         = "AllDNSUDPOutBound"
    description                  = null
    priority                     = "102"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule6 = {
    name                         = "AllDNSUDPInBound"
    description                  = null
    priority                     = "102"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "53"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule7 = {
    name                         = "AllRDPInBound"
    description                  = null
    priority                     = "103"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "3389"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# Data Subnet
datatbddev01_subnet_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# Private Endpoint Subnet
petbddev01_subnet_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}

# Key Vault Subnet
kvtbddev01_subnet_network_security_group_rules = {
rule1 = {
    name                         = "AllHTTPSOutBound"
    description                  = null
    priority                     = "100"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
  rule2 = {
    name                         = "AllHTTPSInBound"
    description                  = null
    priority                     = "100"
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_port_ranges           = null
    destination_port_range       = "443"
    destination_port_ranges      = null
    source_address_prefix        = "*"
    source_address_prefixes      = null
    destination_address_prefix   = "*"
    destination_address_prefixes = null
  }
}