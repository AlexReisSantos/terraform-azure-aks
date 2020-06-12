resource "azurerm_kubernetes_cluster_node_pool" "aks" {

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }

  for_each = var.additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  name                  = substr(each.key, 0, 12)
  vm_size               = each.value.vm_size
  enable_auto_scaling   = each.value.enable_auto_scaling
  node_count            = each.value.node_count
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  max_pods              = each.value.max_pods
  node_taints           = each.value.taints
}

