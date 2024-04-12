resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  location  = azurerm_resource_group.aks_rg.location
  parent_id = azurerm_resource_group.aks_rg.id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

# Create container registry for cluster:
resource "azurerm_container_registry" "acr" {
  name                = "${var.aks_name}acr"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = var.aks_container_registry_sku
}

# Networking:
resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks_vnet_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = var.network_vnet_address_space
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.network_subnet_address_prefixes
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location                  = azurerm_resource_group.aks_rg.location
  name                      = var.aks_name
  resource_group_name       = azurerm_resource_group.aks_rg.name
  node_resource_group       = "${azurerm_resource_group.aks_rg.name}-node"
  dns_prefix                = "${var.aks_name}dns"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  sku_tier                  = "Free"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = var.node_pool_name
    vm_size        = var.node_pool_vm_size
    node_count     = var.node_pool_count
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  linux_profile {
    admin_username = var.aks_admin_username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }

  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = var.network_load_balancer_sku
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

# Allow the nodes to pull container for registry:
resource "azurerm_role_assignment" "ArchPull" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

