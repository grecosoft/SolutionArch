terraform {
  required_version = ">=1.0"

  backend "azurerm" {
    key                  = "solution.tfstate"
  }
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.82.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscriptionId
  tenant_id = var.tenantid 
}

// The org_service_url and personal_access_token must be set when executing the configuration.
// This can be done by setting the AZDO_ORG_SERVICE_URL and AZDO_PERSONAL_ACCESS_TOKEN environment variables.
provider "azuredevops" {
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}