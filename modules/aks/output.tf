output "service_principal_id" {
  description = "Service Principal ID"
  value = azurerm_kubernetes_cluster.k8s.service_principal[0].client_id
}

output "service_principal_secret" {
  description = "Service Principal Secrets"
  value = azurerm_kubernetes_cluster.k8s.service_principal[0].client_secret
}

output "kube_config_raw" {
  description = "Client configuration file for connecting to the cluster"
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "config" {
  description = "Commands to configure kubectl local"
  value = <<EOF
Run the following commands to configure kubectl local:
$ terraform output kube_config_raw > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig
EOF

}