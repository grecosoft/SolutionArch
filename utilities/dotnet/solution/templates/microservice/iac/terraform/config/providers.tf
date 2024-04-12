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
  }
}

provider "azurerm" {
  features {}
}