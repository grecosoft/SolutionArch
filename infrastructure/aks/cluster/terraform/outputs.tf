output "resource_group_name" {
  description = "The name of the resource group containing the cluster."
  value       = azurerm_resource_group.aks_rg.name
}

output "cluster_name" {
  description = "The name of the created cluster."
  value       = azurerm_kubernetes_cluster.k8s.name
}

output "registry_name" {
  description = "The name of the container registry."
  value       = azurerm_container_registry.acr.name
}

output "cluster_vnet_name" {
  description = "The name of the VNet asscoated with the cluster."
  value       = azurerm_virtual_network.aks_vnet.name
}

output "oidc_issuer_url" {
  description = "OIDC Issuer URL used to create federated identity credentials associated with cluster."
  value       = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
}