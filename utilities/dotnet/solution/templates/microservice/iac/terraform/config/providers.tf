terraform {
  required_version = ">=1.0"

  backend "azurerm" {
    // The resource_group_name, storage_account_name, container_name for the solution's 
    // Terraform storage, for a specific environment, are passed by setting the
    // -backend-config argument when initializing the configuration.  

    // The Terraform state for a service is stored within the same solution's environment
    // container using a key specific to the service.
    key                  = "service.[nf:service-name].tfstate"
  }
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.82.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscriptionId
  tenant_id       = var.tenantid
}

// This provider is configured by setting the AZDO_ORG_SERVICE_URL and AZDO_PERSONAL_ACCESS_TOKEN environment variables.
provider "azuredevops" {
}