output "service_principal_id" {
  value = azuread_service_principal.sp.id
}

output "service_principal_secret" {
  value = random_string.unique.result
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "config" {
  value = <<EOF
Run the following commands to configure kubectl local:
$ terraform output kube_config_raw > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig
EOF

}