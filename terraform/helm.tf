data "azurerm_client_config" "current" {
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)

    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  }
}

resource "helm_release" "external-dns" {
  name              = "external-dns"
  chart             = "./helm/external-dns"
  namespace         = "external-dns"
  create_namespace  = true
  dependency_update = true

  values = [templatefile("./templates/external-dns-values.yaml.tftpl", {
    tenantId = data.azurerm_client_config.current.tenant_id
    subscriptionId = data.azurerm_client_config.current.subscription_id
    resourceGroup = azurerm_resource_group.rg.name
    clientId = azurerm_user_assigned_identity.workload-identity.client_id
  })]

  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "helm_release" "cgm" {
  name              = "cgm"
  chart             = "./helm/cgm"
  namespace         = "cgm"
  create_namespace  = true
  dependency_update = true

  values = [templatefile("./templates/cgm-values.yaml.tftpl", {
    username = var.github_username
    password = var.github_token
    clientId = azurerm_user_assigned_identity.workload-identity.client_id
  })]

  depends_on = [helm_release.external-dns]
}