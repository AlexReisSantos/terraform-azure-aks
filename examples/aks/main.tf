provider "azurerm" {
  version = "~> 2.2.0"
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
  source = "../../modules/aks"

  service_principal_id      = var.service_principal_id
  service_principal_secret  = var.service_principal_secret
  prefix                    = var.prefix
  admin_username            = var.admin_username
  location                  = azurerm_resource_group.rg.location
  netwok_resource_group     = azurerm_virtual_network.vnet.resource_group_name
  network_subnet            = azurerm_subnet.subnet.name
  network_vnet              = azurerm_virtual_network.vnet.name
  auto_scaling_default_node = var.auto_scaling_default_node
  node_count                = var.node_count
  node_max_count            = var.node_max_count
  node_min_count            = var.node_min_count
  resource_group            = azurerm_resource_group.rg.name
  storage_account_name      = var.storage_account_name

  additional_node_pools = {
    ss = {
      vm_size             = "Standard_DS2_v2"
      enable_auto_scaling = false
      node_count          = 1
      min_count           = null
      max_count           = null
      max_pods            = 110
      taints              = ["dedicated=searchstation:NoSchedule"]
    }
    rabbitmq = {
      vm_size             = "Standard_DS2_v2"
      enable_auto_scaling = false
      node_count          = 1
      min_count           = null
      max_count           = null
      max_pods            = 110
      taints              = ["dedicated=rabbitmq:NoSchedule"]
    }
    elastic = {
      vm_size             = "Standard_DS2_v2"
      enable_auto_scaling = false
      node_count          = 1
      min_count           = null
      max_count           = null
      max_pods            = 110
      taints              = ["dedicated=elasticsearch:NoSchedule"]
    }
  }

  tags = var.tags
}
