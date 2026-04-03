# ===== Azure AKS Outputs =====

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

output "aks_kube_config_raw" {
  description = "Raw Kubernetes config file for kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

# ===== Azure Resource Group =====

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.rg.location
}

# ===== Container Registry =====

output "acr_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "The Username associated with the Container Registry Admin account"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "The Password associated with the Container Registry Admin account"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "acr_id" {
  description = "The ID of the Container Registry"
  value       = azurerm_container_registry.acr.id
}

# ===== Log Analytics =====

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.aks.id
}

# ===== Configure kubectl =====

output "aks_configure_kubectl" {
  description = "Command to get AKS credentials for kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

# ===== Connection String =====

output "aks_connection_summary" {
  description = "Summary of AKS connection details"
  value = {
    cluster_name       = azurerm_kubernetes_cluster.aks.name
    resource_group     = azurerm_resource_group.rg.name
    location           = azurerm_resource_group.rg.location
    kubernetes_version = azurerm_kubernetes_cluster.aks.kubernetes_version
    node_count         = var.aks_node_count
  }
}