# Public IP for the LB
resource "azurerm_public_ip" "websrv_lb_pub_ip" {
  name                = var.lb_pub_ip_name
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# LB 
resource "azurerm_lb" "websrv_lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.rg_name
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
  network_interface_id = var.network_interface_ids
  ip_configuration_name   = var.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id
}

# LB Probe / health check
resource "azurerm_lb_probe" "web_lb_probe" {
  name            = var.web_lb_probe_name
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
