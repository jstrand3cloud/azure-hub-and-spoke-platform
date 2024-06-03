#------------------------------
# OUTPUTS
#------------------------------

output "virtual_network_mgmt_id" {
  value = module.virtual_network_mgmt.id
}
output "storage_account_id" {
  value = module.storage_account_nsgflow.id
}
output "log_analytics_workspace_id" {
  value = module.log_analytics_workspace.id
}
output "log_analytics_workspace_workspace_id" {
  value = module.log_analytics_workspace.workspace_id
}
output "log_analytics_workspace_location" {
  value = module.log_analytics_workspace.location
}
output "log_analytics_workspace_key" {
  value = module.log_analytics_workspace.primary_shared_key
}
output "log_analytics_workspace_rg" {
  value = module.resource_group_mgmt.name
}
output "kv_subnet_id" {
  value = module.kv_subnet.id
}
output "tfstate_subnet_id" {
  value = module.tfstate_subnet.id
}
output "nsgflow_subnet_id" {
  value = module.nsgflow_subnet.id
}
output "ado_pipeline_agents_subnet_id" {
  value = module.ado_pipeline_agents_subnet.id
}
output "bastion_subnet_id" {
  value = module.bastion_subnet.id
}
output "cloudops_action_group_id" {
  value = azurerm_monitor_action_group.cloudops_action_group.id
}
output "infosec_action_group_id" {
  value = azurerm_monitor_action_group.infosec_action_group.id
}
output "managed_identity_sandbox_cleanup_id" {
  value = azurerm_user_assigned_identity.managed_identity_sandbox_cleanup.id
}
output "management_kv_dns_zone_id" {
  value = azurerm_private_dns_zone.keyvault_dns_zone.id
}