terraform {
  required_version = ">=1.0"

  backend "azurerm" {
    container_name       = "infrastructure"
    key                  = "cluster.tfstate"
  }
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.82.0"
    }
    azapi = {
      source = "azure/azapi"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}
