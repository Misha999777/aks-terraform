provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)

    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "1.15.3"
  namespace  = "cert-manager"

  create_namespace  = true

  values = [yamlencode({
    installCRDs = true
  })]

  depends_on = [azurerm_role_assignment.dns_zone_contributor]
}

resource "helm_release" "cgm" {
  name      = "cgm"
  chart     = "./helm/cgm"
  namespace = "cgm"

  dependency_update = true

  values = [templatefile("./templates/cgm-values.yaml.tftpl", {
    username = var.github_username
    password = var.github_token
    clientId = azurerm_user_assigned_identity.workload-identity.client_id
  })]

  depends_on = [azurerm_role_assignment.storage_blob_contributor]
}
