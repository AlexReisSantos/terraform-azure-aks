resource "azurerm_kubernetes_cluster" "k8s" {

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
    availability_zones  = var.availability_zones
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

