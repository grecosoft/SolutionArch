resource "azurerm_resource_group" "terraform" {
  name     = "${var.storage_resource_group_name}"
  location = "eastus"
}

resource "azurerm_storage_account" "terraform" {
  name                     = "${var.state_storage_account_name}"
  resource_group_name      = azurerm_resource_group.terraform.name
  location                 = azurerm_resource_group.terraform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// Infastructure Terraform State Storage:
resource "azurerm_storage_container" "infrastructure" {
  name                  = "infrastructure"
  storage_account_name  = azurerm_storage_account.terraform.name
  container_access_type = "private"
}
