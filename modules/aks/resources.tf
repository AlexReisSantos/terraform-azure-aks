locals {
  prefix    = var.prefix
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

resource "null_resource" "create_kube_config" {
  provisioner "local-exec" {
    command = "terraform output kube_config_raw > ${azurerm_kubernetes_cluster.k8s.name}_config"
  }
}