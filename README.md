[![Build Status](https://kantarware.visualstudio.com/KM-Engineering-AMS/_apis/build/status/edalferes.terraform-azure-aks?branchName=master)](https://kantarware.visualstudio.com/KM-Engineering-AMS/_build/latest?definitionId=3049&branchName=master)

# terraform-azure-aks

Terraform module to deploy an aks cluster at azure

## Description

This module creates an aks cluster and a `service pricipal` dedicated to its resources, a virtual network and subnet needs to be previously created. There is also the option to create a `storage account` of the MC resource group, to be used as persistence.

## Example usage

- Creating a cluster containing a single node

```hcl
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
  source = "../"

  prefix                    = "my-cluster"
  admin_username            = "my-user-admin"
  location                  = azurerm_resource_group.rg.location
  netwok_resource_group     = azurerm_virtual_network.vnet.resource_group_name
  network_subnet            = azurerm_subnet.subnet.name
  network_vnet              = azurerm_virtual_network.vnet.name
  auto_scaling_default_node = false
  node_count                = 1
  node_max_count            = null
  node_min_count            = null
  resource_group            = azurerm_resource_group.rg.name
  storage_account_name      = mystorageaccountaks

  tags = var.tags
}

```
- Creating a cluster containing several additional nodes

```hcl
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
  source = "../"

  prefix                    = "my-cluster"
  admin_username            = "my-user-admin"
  location                  = azurerm_resource_group.rg.location
  netwok_resource_group     = azurerm_virtual_network.vnet.resource_group_name
  network_subnet            = azurerm_subnet.subnet.name
  network_vnet              = azurerm_virtual_network.vnet.name
  auto_scaling_default_node = false
  node_count                = 1
  node_max_count            = null
  node_min_count            = null
  resource_group            = azurerm_resource_group.rg.name
  storage_account_name      = mystorageaccountaks

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

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_node\_pools | (Optional) List of additional node pools to the cluster | <pre>map(object({<br>    vm_size             = string<br>    enable_auto_scaling = bool<br>    node_count          = number<br>    min_count           = number<br>    max_count           = number<br>    max_pods            = number<br>    taints              = list(string)<br>  }))</pre> | `{}` | no |
| admin\_username | (Required) The Admin Username for the Cluster. Changing this forces a new resource to be created. | `string` | n/a | yes |
| auto\_scaling\_default\_node | (Optional) Kubernetes Auto Scaler must be enabled for this main pool | `bool` | n/a | yes |
| dns\_service\_ip | (Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). | `string` | `"10.0.0.10"` | no |
| docker\_bridge\_cidr | (Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created. | `string` | `"172.17.0.1/16"` | no |
| end\_date | The End Date which the Password is valid until, formatted as a RFC3339 date string (e.g. 2018-01-01T01:02:03Z). | `string` | `"2030-01-01T00:00:00Z"` | no |
| k8s\_version | (Optional) Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). | `string` | `"1.15.10"` | no |
| location | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| max\_pods | (Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. | `number` | `110` | no |
| netwok\_resource\_group | (Required) Name of the resource group that contains the virtual network | `string` | n/a | yes |
| network\_subnet | (Required) Network subnet name. | `string` | n/a | yes |
| network\_vnet | (Required) Virtual network name. | `string` | n/a | yes |
| node\_count | (Optional) The initial number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100 and between min\_count and max\_count. | `string` | n/a | yes |
| node\_max\_count | (Required) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100. | `number` | n/a | yes |
| node\_min\_count | (Required) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100. | `number` | n/a | yes |
| pod\_cidr | (Optional) The CIDR to use for pod IP addresses. Changing this forces a new resource to be created. | `string` | `"10.244.0.0/16"` | no |
| prefix | (Required) Base name used by resources (cluster name, main service and others). | `string` | n/a | yes |
| rbac\_enabled | (Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created. | `bool` | `false` | no |
| resource\_group | (Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| service\_cidr | (Optional) The Network Range used by the Kubernetes service.Changing this forces a new resource to be created. | `string` | `"10.0.0.0/16"` | no |
| storage\_account\_kind | (Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to StorageV2. | `string` | `"FileStorage"` | no |
| storage\_account\_name | (Optional) Data storage name (use lower case, no spaces and special characters ex: mystorageaccount).null empty does not create resource. | `string` | n/a | yes |
| storage\_account\_replication\_type | (Required) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS. | `string` | `"LRS"` | no |
| storage\_account\_tier | (Required) Defines the Tier to use for this storage account. Valid options are Standard and Premium. For FileStorage accounts only Premium is valid. Changing this forces a new resource to be created. | `string` | `"Premium"` | no |
| tags | (Optional) A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |
| vm\_size | (Required) The size of the Virtual Machine, such as Standard\_DS2\_v2. | `string` | `"Standard_DS2_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| config | Commands to configure kubectl local |
| kube\_config\_raw | Client configuration file for connecting to the cluster |
| service\_principal\_id | Service Principal ID |
| service\_principal\_secret | Service Principal Secrets |

