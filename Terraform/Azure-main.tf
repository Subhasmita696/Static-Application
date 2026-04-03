# ===== Azure Resource Group =====
resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg-${var.environment}"
  location = var.azure_location

  tags = var.tags
}

# ===== Azure Kubernetes Service (AKS) =====
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.project_name}-aks-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.project_name}aks"
  kubernetes_version  = var.aks_kubernetes_version

  # Default node pool
  default_node_pool {
    name                = "default"
    node_count          = var.aks_node_count
    vm_size             = var.aks_vm_size
    os_disk_size_gb     = 50
    os_disk_type        = "Managed"
    enable_auto_scaling = true
    min_count           = var.aks_node_count
    max_count           = 5
    vnet_subnet_id      = azurerm_subnet.aks.id

    node_labels = {
      Environment = var.environment
      Project     = var.project_name
    }

    tags = var.tags
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin      = "azure"
    load_balancer_sku   = "standard"
    service_cidr        = "10.1.0.0/16"
    dns_service_ip      = "10.1.0.10"
    docker_bridge_cidr  = "172.17.0.1/16"
    pod_cidr            = "10.244.0.0/16"
    network_policy      = "azure"
    outbound_type       = "loadBalancer"
  }

  # Monitoring
  azure_policy_enabled             = true
  http_application_routing_enabled = false
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  # API server access
  api_server_access_profile {
    authorized_ip_ranges = ["0.0.0.0/0"]  # Change to restrict IPs in production
  }

  # Key vault secrets provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.aks_identity
  ]
}

# ===== Virtual Network & Subnet =====
resource "azurerm_virtual_network" "aks" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/8"]

  tags = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.240.0.0/16"]
}

# ===== Log Analytics Workspace =====
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.project_name}-la-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "aks" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  workspace_name        = azurerm_log_analytics_workspace.aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# ===== Role Assignment for AKS Identity =====
resource "azurerm_role_assignment" "aks_identity" {
  scope              = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# ===== Container Registry =====
resource "azurerm_container_registry" "acr" {
  name                = "${var.project_name}acr${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.tags
}

# ===== Role Assignment - AKS to ACR =====
resource "azurerm_role_assignment" "aks_acr" {
  scope              = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}