provider "azurerm" {
  version = "~> 2.2.0"
  features {}
}

module "aks" {
  source = "../"

  prefix                    = "terraform-aks"
  admin_username            = "terraform"
  location                  = azurerm_resource_group.rg.location
  netwok_resource_group     = azurerm_virtual_network.vnet.resource_group_name
  network_subnet            = azurerm_subnet.subnet.name
  network_vnet              = azurerm_virtual_network.vnet.name
  auto_scaling_default_node = false
  node_count                = 1
  node_max_count            = null
  node_min_count            = null
  resource_group            = azurerm_resource_group.rg.name
  storage_account_name      = null

  tags = {
    "MAINTAINER" = "Azure Devops CI"
  }
}
