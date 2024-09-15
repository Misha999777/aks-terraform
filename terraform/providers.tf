terraform {
  required_version = ">=1.0"

  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~> 3.6.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.41.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15.0"
    }
  }
}

provider "azurerm" {
  features {}
}
