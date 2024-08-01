# Creates a storage account used to store the Terraform state
# within a solution specific resource group.
resource "azurerm_resource_group" "terraform" {
  name     = "${var.resource_group_name}"
  location = "eastus"
}

resource "azurerm_storage_account" "terraform" {
  name                     = "${var.storage_account_name}"
  resource_group_name      = azurerm_resource_group.terraform.name
  location                 = azurerm_resource_group.terraform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create storage container to store Terraform state for each environment:
resource "azurerm_storage_container" "[nf:solution-name]-dev" {
  name                  = "[nf:solution-name]-dev"
  storage_account_name  = azurerm_storage_account.terraform.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "[nf:solution-name]-stg" {
  name                  = "[nf:solution-name]-stg"
  storage_account_name  = azurerm_storage_account.terraform.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "[nf:solution-name]-prd" {
  name                  = "[nf:solution-name]-prd"
  storage_account_name  = azurerm_storage_account.terraform.name
  container_access_type = "private"
}