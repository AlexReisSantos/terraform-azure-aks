/**
* [![Build Status](https://kantarware.visualstudio.com/KM-Engineering-AMS/_apis/build/status/edalferes.terraform-azure-aks?branchName=master)](https://kantarware.visualstudio.com/KM-Engineering-AMS/_build/latest?definitionId=3049&branchName=master)
*
* # terraform-azure-aks
*
* Terraform module to deploy an aks cluster at azure
*
* ## Description
*
* This module creates an aks with advanced network, and the network must be previously created and configured. There is also the option to create a `storage account` of the MC resource group, to be used as persistence.
*
* ## Example usage
*
* - Creating a cluster containing a single node
*
* ```hcl
* provider "azurerm" {
*   version = "~> 2.2.0"
*   features {}
* }
*
* resource "azurerm_resource_group" "rg" {
*   name     = "terraform-aks"
*   location = "westus"
* }
*
* resource "azurerm_virtual_network" "vnet" {
*   name                = "terraform-aks-vnet"
*   address_space       = ["10.30.0.0/16"]
*   location            = azurerm_resource_group.rg.location
*   resource_group_name = azurerm_resource_group.rg.name
* }
*
* resource "azurerm_subnet" "subnet" {
*   name                 = "terraform-aks-subnet"
*   resource_group_name  = azurerm_resource_group.rg.name
*   virtual_network_name = azurerm_virtual_network.vnet.name
*   address_prefix       = "10.30.1.0/24"
* }
*
* module "aks" {
*   source = "../"
*
*   service_principal_id      = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
*   service_principal_secret  = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
*   prefix                    = "my-cluster"
*   admin_username            = "my-user-admin"
*   location                  = azurerm_resource_group.rg.location
*   netwok_resource_group     = azurerm_virtual_network.vnet.resource_group_name
*   network_subnet            = azurerm_subnet.subnet.name
*   network_vnet              = azurerm_virtual_network.vnet.name
*   auto_scaling_default_node = false
*   node_count                = 1
*   node_max_count            = null
*   node_min_count            = null
*   resource_group            = azurerm_resource_group.rg.name
*   storage_account_name      = mystorageaccountaks
*
*   tags = var.tags
* }
*
* ```
* - Creating a cluster containing several additional nodes
*
* ```hcl
* provider "azurerm" {
*   version = "~> 2.2.0"
*   features {}
* }
*
* resource "azurerm_resource_group" "rg" {
*   name     = "terraform-aks"
*   location = "westus"
* }
*
* resource "azurerm_virtual_network" "vnet" {
*   name                = "terraform-aks-vnet"
*   address_space       = ["10.30.0.0/16"]
*   location            = azurerm_resource_group.rg.location
*   resource_group_name = azurerm_resource_group.rg.name
* }
*
* resource "azurerm_subnet" "subnet" {
*   name                 = "terraform-aks-subnet"
*   resource_group_name  = azurerm_resource_group.rg.name
*   virtual_network_name = azurerm_virtual_network.vnet.name
*   address_prefix       = "10.30.1.0/24"
* }
*
* module "aks" {
*   source = "../"
*
*   service_principal_id      = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
*   service_principal_secret  = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
*   prefix                    = "my-cluster"
*   admin_username            = "my-user-admin"
*   location                  = azurerm_resource_group.rg.location
*   netwok_resource_group     = azurerm_virtual_network.vnet.resource_group_name
*   network_subnet            = azurerm_subnet.subnet.name
*   network_vnet              = azurerm_virtual_network.vnet.name
*   auto_scaling_default_node = false
*   node_count                = 1
*   node_max_count            = null
*   node_min_count            = null
*   resource_group            = azurerm_resource_group.rg.name
*   storage_account_name      = mystorageaccountaks
*
*   additional_node_pools = {
*     ss = {
*       vm_size             = "Standard_DS2_v2"
*       enable_auto_scaling = false
*       node_count          = 1
*       min_count           = null
*       max_count           = null
*       max_pods            = 110
*       taints              = ["dedicated=searchstation:NoSchedule"]
*     }
*     rabbitmq = {
*       vm_size             = "Standard_DS2_v2"
*       enable_auto_scaling = false
*       node_count          = 1
*       min_count           = null
*       max_count           = null
*       max_pods            = 110
*       taints              = ["dedicated=rabbitmq:NoSchedule"]
*     }
*     elastic = {
*       vm_size             = "Standard_DS2_v2"
*       enable_auto_scaling = false
*       node_count          = 1
*       min_count           = null
*       max_count           = null
*       max_pods            = 110
*       taints              = ["dedicated=elasticsearch:NoSchedule"]
*     }
*   }
*
*   tags = var.tags
* }
*
* ```
*/

resource "azurerm_kubernetes_cluster" "k8s" {

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
    ]
  }

  name                = local.prefix
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  dns_prefix          = "${local.prefix}-dns"
  kubernetes_version  = var.k8s_version

  linux_profile {

    admin_username = var.admin_username

    ssh_key {
      key_data = tls_private_key.pair.public_key_openssh
    }
  }

  default_node_pool {
    name                = "main"
    vm_size             = var.vm_size
    vnet_subnet_id      = local.subnet_id
    enable_auto_scaling = var.auto_scaling_default_node
    node_count          = var.node_count
    min_count           = var.node_min_count
    max_count           = var.node_max_count
    max_pods            = var.max_pods
  }

  service_principal {
    client_id     = var.service_principal_id
    client_secret = var.service_principal_secret
  }

  role_based_access_control {
    enabled = var.rbac_enabled
  }

  network_profile {
    network_plugin     = "kubenet"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    pod_cidr           = var.pod_cidr
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  tags = var.tags
}

