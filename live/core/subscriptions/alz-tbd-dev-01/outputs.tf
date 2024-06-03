#------------------------------
# OUTPUTS
#------------------------------

output "virtual_network_tbddev01_id" {
  value = module.virtual_network_tbddev01.id
}
output "apptbddev01_subnet_id" {
  value = module.apptbddev01_subnet.id
}
output "datatbddev01_subnet_id" {
  value = module.datatbddev01_subnet.id
}
output "petbddev01_subnet_id" {
  value = module.petbddev01_subnet.id
}
output "kvtbddev01_subnet_id" {
  value = module.kvtbddev01_subnet.id
}