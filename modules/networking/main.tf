# Resource group for all resources
resource "azurerm_resource_group" "websrv_rg" {
  name     = var.rg_name
  location = var.location
}

# VNet
resource "azurerm_virtual_network" "websrv_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.rg_name
}

# Private subnet - for the web server
resource "azurerm_subnet" "websrv_private_subnet" {
  name                 = "${var.prefix}-private-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.websrv_vnet.name
  address_prefixes     = var.address_prefixes_int
}

# Public subnet - for the load balancer
resource "azurerm_subnet" "websrv_public_subnet" {
  name                 = "${var.prefix}-public-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.websrv_vnet.name
  address_prefixes     = var.address_prefixes_ext
}

# Public subnet for the bastion
resource "azurerm_subnet" "websrv_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.websrv_vnet.name
  address_prefixes     = var.address_prefixes_bastion
}

# Associating the web instance with the private subnet
resource "azurerm_network_interface" "websrv_net_interface" {
  name                = "mywebsrv-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websrv_private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Web server security group to control the traffic in the private subnet
resource "azurerm_network_security_group" "websrv_private_sg" {
  name                = var.rg_name
  location            = var.location
  resource_group_name = var.rg_name
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
  resource_group_name         = var.rg_name
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
  resource_group_name         = var.rg_name
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
  resource_group_name         = var.rg_name
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
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.websrv_private_sg.name
}

# Associate the NSG with the private subnet
resource "azurerm_subnet_network_security_group_association" "websrv_association" {
  subnet_id                 = azurerm_subnet.websrv_private_subnet.id
  network_security_group_id = azurerm_network_security_group.websrv_private_sg.id
}

# Bastion Public IP
resource "azurerm_public_ip" "websrv_bastion_pub_ip" {
  name                = var.pub_bastion_ip_name
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion host
resource "azurerm_bastion_host" "websrv_bastion" {
  name                = "${var.prefix}-bastion"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                 = var.bastion_pub_ip_config
    subnet_id            = azurerm_subnet.websrv_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.websrv_bastion_pub_ip.id
  }
}