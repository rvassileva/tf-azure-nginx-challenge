variable "prefix" {
  default     = "MyWebServer"
  description = "The prefix used for the names of the resources."
}

variable "rg_name" {
  default     = "MyWebServer-nginx-rg"
  description = "The name of the resource group for all resources."
}

variable "location" {
  default     = "West Europe"
  description = "The region where the resources will be deployed."
}

variable "address_space" {
  default     = ["10.0.0.0/16"]
  description = "The address space / CIDR for the virtual network."
}

variable "address_prefixes_int" {
  default     = ["10.0.1.0/24"]
  description = "The private IP of the subnet."
}

variable "address_prefixes_ext" {
  default     = ["10.0.2.0/24"]
  description = "The public IP of the subnet."
}

variable "address_prefixes_bastion" {
  default     = ["10.0.3.0/24"]
  description = "The public IP of the bastion's subnet."
}

variable "lb_pub_ip_name" {
  default     = "PublicIPForLB"
  description = "The name of the public IP of the load balancer."
}

variable "pub_bastion_ip_name" {
  default     = "PubIPForBastionHost"
  description = "The name of the Public IP of the Bastion Host."
}

variable "lb_name" {
  default     = "WebLB"
  description = "The name of the load balancer."
}

variable "instance_name" {
  default     = "MyWebServer"
  description = "The name of the web server VM."
}

variable "vm_size" {
  default     = "Standard_DS1_v2"
  description = "The size of the VM."
}

variable "computer_name" {
  default     = "hostname"
  description = "The computer name."
}

variable "admin_username" {
  default     = "adminuser"
  description = "The username used for the VM."
}

variable "address_pool_name" {
  default     = "BackEndAddressPool"
  description = "The name of the backend address pool."
}

variable "lb_rule_name" {
  default     = "LBRule"
  description = "The name of the load balancer's rule."
}

variable "pub_ip_config" {
  default     = "IPconfigLB"
  description = "The public IP config name of the load balancer."
}

variable "bastion_pub_ip_config" {
  default     = "IPconfigBastion"
  description = "The public IP config name of the Bastion."
}

variable "web_lb_probe_name" {
  default     = "websrv-tcp-lb-probe"
  description = "The name of the webserver LB's probe."
}
