variable "prefix" {
  default = "mywebserver"
}

variable "location" {
  default = "West Europe"
}

variable "address_space" {
  default = ["10.0.0.0/16"]
}

variable "address_prefixes_int" {
  default = ["10.0.1.0/24"]
}

variable "address_prefixes_ext" {
  default = ["10.0.2.0/24"]
}

variable "address_prefixes_bastion" {
  default = ["10.0.3.0/24"]
}

variable "lb_pub_ip_name" {
  default = "PublicIPForLB"
}

variable "pub_bastion_ip_name" {
  default = "PubIPForBastionHost"
}

variable "lb_name" {
  default = "WebLB"
}

variable "instance_name" {
  default = "MyWebServer"
}

variable "vm_size" {
  default = "Standard_DS1_v2"
}

variable "computer_name" {
  default = "hostname"
}

variable "admin_username" {
  default = "adminuser"
}

variable "address_pool_name" {
  default = "BackEndAddressPool"
}

variable "lb_rule_name" {
  default = "LBRule"
}

variable "pub_ip_config" {
  default = "IPconfigLB"
}

variable "bastion_pub_ip_config" {
  default = "IPconfigBastion"
}

variable "lb_out_rule_name" {
  default = "LBOutboundRule"
}