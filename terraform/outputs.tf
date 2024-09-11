output "group_name" {
  value     = azurerm_resource_group.rg.name
  sensitive = false
}

output "cluster_name" {
  value     = azurerm_kubernetes_cluster.k8s.name
  sensitive = false
}