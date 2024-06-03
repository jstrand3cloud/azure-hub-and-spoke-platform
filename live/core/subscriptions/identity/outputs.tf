#------------------------------
# OUTPUTS
#------------------------------

output "virtual_network_identity_id" {
  value = module.virtual_network_identity.id
}
output "kv_subnet_id" {
  value = module.kv_subnet.id
}
output "addc_subnet_id" {
  value = module.addc_subnet.id
}
output "infoblox_subnet_id" {
  value = module.infoblox_subnet.id
}
output "pr_subnet_inbound_id" {
  value = module.pr_subnet_inbound.id
}
output "pr_subnet_outbound_id" {
  value = module.pr_subnet_outbound.id
}
output "identity_kv_dns_zone_id" {
  value = azurerm_private_dns_zone.keyvault_dns_zone.id
}