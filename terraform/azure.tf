# resource group
resource "random_pet" "rg_name" {
  prefix = "rg"
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# cluster
resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

# DNS zone
resource "azurerm_dns_zone" "main" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  name                      = random_pet.azurerm_kubernetes_cluster_name.id
  dns_prefix                = random_pet.azurerm_kubernetes_cluster_name.id
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  web_app_routing {
    dns_zone_ids = [azurerm_dns_zone.main.id]
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "agentpool"
    vm_size             = var.node_type
    os_disk_size_gb     = 32
    min_count           = var.nodes_min
    max_count           = var.nodes_max
    enable_auto_scaling = true
    type                = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

# storage
resource "azurerm_storage_account" "storage" {
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  name                     = "cgmt"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "blob_container" {
  storage_account_name  = azurerm_storage_account.storage.name
  name                  = "cgm-container"
  container_access_type = "private"
}

# identity
resource "azurerm_user_assigned_identity" "workload-identity" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "aks-workload-identity"
}

resource "azurerm_federated_identity_credential" "workload-identity-credential" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "aks-workload-identity-credential"
  parent_id           = azurerm_user_assigned_identity.workload-identity.id
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject             = "system:serviceaccount:cgm:cgm-sa"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "storage_blob_contributor" {
  principal_id         = azurerm_user_assigned_identity.workload-identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.storage.id
}
