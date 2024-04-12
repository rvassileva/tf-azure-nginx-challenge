output "public_ip_address_lb" {
  value = azurerm_public_ip.websrv_lb_pub_ip.ip_address
}

output "private_ip_vm" {
  value = azurerm_linux_virtual_machine.websrv_instance.private_ip_address
}

output "public_ip_bastion" {
  value = azurerm_public_ip.websrv_bastion_pub_ip.ip_address
}