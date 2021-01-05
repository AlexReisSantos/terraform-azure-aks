provider "azurerm" {
  version = "~> 2.35.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "terraform-aks"
  location = "westus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "terraform-aks-vnet"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "terraform-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.30.1.0/24"
}

module "aks" {
  source = "../"

  prefix                    = var.prefix
  admin_username            = var.admin_username
  location                  = azurerm_resource_group.rg.location
  netwok_resource_group     = azurerm_virtual_network.vnet.resource_group_name
  network_subnet            = azurerm_subnet.subnet.name
  network_vnet              = azurerm_virtual_network.vnet.name
  auto_scaling_default_node = var.auto_scaling_default_node
  availability_zones        = ["1","2","3"]
  node_count                = var.node_count
  node_max_count            = var.node_max_count
  node_min_count            = var.node_min_count
  resource_group            = azurerm_resource_group.rg.name
  storage_account_name      = null

  tags = var.tags
}
