variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "address_space" {
  type = any
}

variable "address_prefixes_int" {
  type = list(string)
}

variable "address_prefixes_ext" {
  type = list(string)
}

variable "address_prefixes_bastion" {
  type = list(string)
}

variable "pub_bastion_ip_name" {
  type = string
}

variable "bastion_pub_ip_config" {
  type = string
}
