terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
    }

  }
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "websrv_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# VNet
resource "azurerm_virtual_network" "websrv_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = var.address_space
  location            = azurerm_resource_group.websrv_rg.location
  resource_group_name = azurerm_resource_group.websrv_rg.name
}

# Private subnet - for the web server
resource "azurerm_subnet" "websrv_private_subnet" {
  name                 = "${var.prefix}-private-subnet"
  resource_group_name  = azurerm_resource_group.websrv_rg.name
  virtual_network_name = azurerm_virtual_network.websrv_vnet.name
  address_prefixes     = var.address_prefixes_int
}

# Public subnet - for the load balancer
resource "azurerm_subnet" "websrv_public_subnet" {
  name                 = "${var.prefix}-public-subnet"
  resource_group_name  = azurerm_resource_group.websrv_rg.name
  virtual_network_name = azurerm_virtual_network.websrv_vnet.name
  address_prefixes     = var.address_prefixes_ext
}

# Public subnet for the bastion
resource "azurerm_subnet" "websrv_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.websrv_rg.name
  virtual_network_name = azurerm_virtual_network.websrv_vnet.name
  address_prefixes     = var.address_prefixes_bastion
}

# Associating the web instance with the private subnet
resource "azurerm_network_interface" "websrv_net_interface" {
  name                = "${var.prefix}-ni"
  location            = azurerm_resource_group.websrv_rg.location
  resource_group_name = azurerm_resource_group.websrv_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websrv_private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Web server security group to control the traffic in the private subnet
resource "azurerm_network_security_group" "websrv_private_sg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.websrv_rg.location
  resource_group_name = azurerm_resource_group.websrv_rg.name
}

# Rule to allow traffic from load balancer's public IP
resource "azurerm_network_security_rule" "websrv_private_sg_all_in" {
  name                        = "allow-all-inbound-traffic"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.websrv_rg.name
  network_security_group_name = azurerm_network_security_group.websrv_private_sg.name
}

# Rule to allow traffic from the bastion to the instance
resource "azurerm_network_security_rule" "websrv_private_sg_bastion_in" {
  name                        = "allow-ssh-from-bastion"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_public_ip.websrv_bastion_pub_ip.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.websrv_rg.name
  network_security_group_name = azurerm_network_security_group.websrv_private_sg.name
}

# Rule to deny all inbound traffic to the web server - lower priority rule
resource "azurerm_network_security_rule" "websrv_private_sg_deny_all_in" {
  name                        = "deny-all-inbound-traffic"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.websrv_rg.name
  network_security_group_name = azurerm_network_security_group.websrv_private_sg.name
}

resource "azurerm_network_security_rule" "websrv_private_sg_allow_all_out" {
  name                        = "allow-all-outbound-traffic"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.websrv_rg.name
  network_security_group_name = azurerm_network_security_group.websrv_private_sg.name
}

# Associate the NSG with the private subnet
resource "azurerm_subnet_network_security_group_association" "websrv_association" {
  subnet_id                 = azurerm_subnet.websrv_private_subnet.id
  network_security_group_id = azurerm_network_security_group.websrv_private_sg.id
}

# Create virtual machine in the private subnet
resource "azurerm_linux_virtual_machine" "websrv_instance" {
  name                  = var.instance_name
  resource_group_name   = azurerm_resource_group.websrv_rg.name
  location              = azurerm_resource_group.websrv_rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.websrv_net_interface.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("tf-az-cloud-init.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.config.rendered
}

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "packages: ['nginx']"
  }
}

# LB Public IP 
resource "azurerm_public_ip" "websrv_lb_pub_ip" {
  name                = var.lb_pub_ip_name
  location            = azurerm_resource_group.websrv_rg.location
  resource_group_name = azurerm_resource_group.websrv_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion Public IP
resource "azurerm_public_ip" "websrv_bastion_pub_ip" {
  name                = var.pub_bastion_ip_name
  location            = azurerm_resource_group.websrv_rg.location
  resource_group_name = azurerm_resource_group.websrv_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion host
resource "azurerm_bastion_host" "websrv_bastion" {
  name                = "${var.prefix}-bastion"
  location            = azurerm_resource_group.websrv_rg.location
  resource_group_name = azurerm_resource_group.websrv_rg.name

  ip_configuration {
    name                 = var.bastion_pub_ip_config
    subnet_id            = azurerm_subnet.websrv_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.websrv_bastion_pub_ip.id
  }
}

# LB 
resource "azurerm_lb" "websrv_lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.websrv_rg.location
  resource_group_name = azurerm_resource_group.websrv_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.pub_ip_config
    public_ip_address_id = azurerm_public_ip.websrv_lb_pub_ip.id
  }
}

# LB backend pool
resource "azurerm_lb_backend_address_pool" "web_lb_backend_address_pool" {
  name            = var.address_pool_name
  loadbalancer_id = azurerm_lb.websrv_lb.id
}

# Associating network interface with backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "websrv_ni_lb_associate" {
  network_interface_id    = azurerm_network_interface.websrv_net_interface.id
  ip_configuration_name   = azurerm_network_interface.websrv_net_interface.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id
}

# LB Probe / health check
resource "azurerm_lb_probe" "web_lb_probe" {
  name            = "${var.prefix}-tcp-lb-probe"
  loadbalancer_id = azurerm_lb.websrv_lb.id
  port            = 80
}

# LB rule for the probe
resource "azurerm_lb_rule" "web_lb_rule" {
  name                           = var.lb_rule_name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.pub_ip_config
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id]
  probe_id                       = azurerm_lb_probe.web_lb_probe.id
  loadbalancer_id                = azurerm_lb.websrv_lb.id
}
