data "azurerm_client_config" "current" {
}

data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    organization = var.organization_name
    workspaces = {
      name = var.workspace_name
    }
  }
}

data "azurerm_kubernetes_cluster" "credentials" {
  resource_group_name = data.terraform_remote_state.cluster.outputs.group_name
  name                = data.terraform_remote_state.cluster.outputs.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config[0].host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config[0].cluster_ca_certificate)

    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config[0].client_key)
  }
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  version          = "6.32.0"
  namespace        = "external-dns"
  create_namespace = true

  values = [templatefile("./templates/external-dns-values.yaml.tftpl", {
    tenant_id       = data.azurerm_client_config.current.tenant_id
    subscription_id = data.azurerm_client_config.current.subscription_id
    rg_name         = data.terraform_remote_state.cluster.outputs.group_name
    client_id       = data.terraform_remote_state.cluster.outputs.principal
  })]

  depends_on = [data.azurerm_kubernetes_cluster.credentials]
}

resource "helm_release" "pull-secret" {
  name       = "pull-secret"
  chart      = "./helm/pull-secret"

  values = [templatefile("./templates/pull-secret-values.yaml.tftpl", {
    username = var.github_username
    password = var.github_password
  })]

  depends_on = [data.azurerm_kubernetes_cluster.credentials]
}