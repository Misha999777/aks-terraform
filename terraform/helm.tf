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

resource "helm_release" "aksplorer" {
  name      = "aksplorer"
  chart     = "./helm/aksplorer"
  namespace = "aksplorer"

  dependency_update = true
  create_namespace  = true

  values = [templatefile("./templates/aksplorer-values.yaml.tftpl", {
    clientId       = azurerm_user_assigned_identity.workload-identity.client_id
    githubUsername = var.github_username
    githubPassword = var.github_token
    clusterDomain  = var.cluster_domain_name
    acmeEmail      = var.acme_email
  })]

  depends_on = [helm_release.cert_manager]
}
