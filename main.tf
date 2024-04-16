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

module "networking" {
  source                   = "./modules/networking"
  prefix                   = var.prefix
  location                 = var.location
  rg_name                  = var.rg_name
  address_space            = var.address_space
  address_prefixes_int     = var.address_prefixes_int
  address_prefixes_ext     = var.address_prefixes_ext
  address_prefixes_bastion = var.address_prefixes_bastion
  pub_bastion_ip_name      = var.pub_bastion_ip_name
  bastion_pub_ip_config    = var.bastion_pub_ip_config
}

module "compute" {
  source                = "./modules/compute"
  location              = module.networking.location
  rg_name               = module.networking.websrv_rg
  instance_name         = var.instance_name
  vm_size               = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = module.networking.network_interface_ids
}

module "load-balancer" {
  source                = "./modules/load-balancer"
  location              = module.networking.location
  rg_name               = module.networking.websrv_rg
  lb_name               = var.lb_name
  pub_ip_config         = var.pub_ip_config
  address_pool_name     = var.address_pool_name
  lb_rule_name          = var.lb_rule_name
  web_lb_probe_name     = var.web_lb_probe_name
  network_interface_ids = module.networking.network_interface_ids
  ip_configuration_name = module.networking.ip_configuration_name
  lb_pub_ip_name        = var.lb_pub_ip_name
}