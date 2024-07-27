terraform {
  required_version = ">=1.0"

  backend "azurerm" {
    key                  = "microservice.[nf:service-name].tfstate"
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
}

// This can be done by setting the AZDO_ORG_SERVICE_URL and AZDO_PERSONAL_ACCESS_TOKEN environment variables.
provider "azuredevops" {
}