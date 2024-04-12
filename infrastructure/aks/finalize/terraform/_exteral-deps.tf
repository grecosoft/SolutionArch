data "terraform_remote_state" "custer" {
  backend = "azurerm"

  config = {
    resource_group_name  = "${var.storage_resource_group_name}"
    storage_account_name = "${var.state_storage_account_name}"
    container_name       = "infrastructure"
    key                  = "cluster.tfstate"
  }
}

locals {
  cluster_resource_group_name = data.terraform_remote_state.custer.outputs.resource_group_name
  cluster_name                = data.terraform_remote_state.custer.outputs.cluster_name
  cluster_vnet_name           = data.terraform_remote_state.custer.outputs.cluster_vnet_name
  oidc_issuer_url             = data.terraform_remote_state.custer.outputs.oidc_issuer_url
}