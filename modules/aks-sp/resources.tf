locals {

  prefix    = var.prefix
  sp_name   = "${var.prefix}-sp"
  subnet_id = data.azurerm_subnet.subnet.id
  location  = var.location
  tags      = var.tags
}

data "azurerm_subnet" "subnet" {
  name                 = var.network_subnet
  virtual_network_name = var.network_vnet
  resource_group_name  = var.netwok_resource_group
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

resource "tls_private_key" "pair" {
  algorithm = "RSA"
}