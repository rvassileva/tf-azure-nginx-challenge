variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "pub_ip_config" {
  type = any
}

variable "address_pool_name" {
  type = string
}

variable "lb_rule_name" {
  type = string
}

variable "web_lb_probe_name" {
  type = string
}

variable "network_interface_ids" {
}

variable "ip_configuration_name" {
}

variable "lb_pub_ip_name" {
  type = string
}