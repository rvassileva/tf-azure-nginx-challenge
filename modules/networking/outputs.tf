output "websrv_public_subnet" {
  value = azurerm_subnet.websrv_public_subnet.id
}

output "websrv_private_subnet" {
  value = azurerm_subnet.websrv_private_subnet.id
}

output "websrv_net_interface" {
  value = azurerm_network_interface.websrv_net_interface.id
}

output "public_ip_bastion" {
  value = azurerm_public_ip.websrv_bastion_pub_ip.ip_address
}

output "network_interface_ids" {
  value = azurerm_network_interface.websrv_net_interface.id
}

output "ip_configuration_name" {
  value = azurerm_network_interface.websrv_net_interface.ip_configuration[0].name
}

output "websrv_rg" {
 value = azurerm_resource_group.websrv_rg.name 
}

output "location" {
  value = azurerm_resource_group.websrv_rg.location
}