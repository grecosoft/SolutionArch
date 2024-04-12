// Application Gateway for Containers is a new application (layer 7) load balancing and dynamic traffic management product for workloads running in a
// Kubernetes cluster. It extends Azure's Application Load Balancing portfolio and is a new offering under the Application Gateway product family.
//
// https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller?tabs=install-helm-windows

data "azurerm_resource_group" "cluster_rg" {
  name = local.cluster_resource_group_name
}

data "azurerm_kubernetes_cluster" "k8s" {
  resource_group_name = local.cluster_resource_group_name
  name                = local.cluster_name
}

// Create a user managed identity for ALB controller and federate the identity as Workload Identity to use in the AKS cluster:
resource "azurerm_user_assigned_identity" "alb_managed_identity" {
  location            = data.azurerm_resource_group.cluster_rg.location
  name                = var.identity_resource_name
  resource_group_name = local.cluster_resource_group_name
}

// Apply Reader role to the AKS managed cluster resource group for the newly provisioned identity:
resource "azurerm_role_assignment" "reader" {
  scope                = data.azurerm_kubernetes_cluster.k8s.node_resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.alb_managed_identity.principal_id
}

// Set up federation with AKS OIDC issuer:
resource "azurerm_federated_identity_credential" "federated" {
  name                = "${var.identity_resource_name}-federated"
  resource_group_name = data.azurerm_resource_group.cluster_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = local.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.alb_managed_identity.id
  subject             = "system:serviceaccount:azure-alb-system:alb-controller-sa" // FIX:  make the ns so it uses var.container_gateway_namespace
}

// The ALB Controller is responsible for translating Gateway API and Ingress API configuration within Kubernetes
// to load balancing rules within Application Gateway for Containers. 
resource "helm_release" "alb-controller" {
  namespace        = var.container_gateway_namespace
  create_namespace = true
  name             = "alb-controller"
  repository       = "oci://mcr.microsoft.com/application-lb/charts/"
  chart            = "alb-controller"

  set {
    name  = "albController.namespace"
    value = var.container_gateway_namespace
  }

  set {
    name  = "albController.podIdentity.clientID"
    value = azurerm_user_assigned_identity.alb_managed_identity.client_id
  }

}

// Create Application Gateway for Containers managed by ALB Controller
// https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-managed-by-alb-controller?tabs=new-subnet-aks-vnet
resource "azurerm_subnet" "alb_subnet" {
  name                 = "alb-subnet"
  resource_group_name  = data.azurerm_resource_group.cluster_rg.name
  virtual_network_name = local.cluster_vnet_name
  address_prefixes     = var.alb_subnet_address_prefixes

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.ServiceNetworking/trafficControllers"
    }
  }
}

// Delegate permissions to managed identity
//   ALB Controller needs the ability to provision new Application Gateway for Containers resources and 
//   to join the subnet intended for the Application Gateway for Containers association resource.

// Delegate AppGw for Containers Configuration Manager role to AKS Managed Cluster RG:
resource "azurerm_role_assignment" "appGwRoleAssign" {
  scope                = data.azurerm_kubernetes_cluster.k8s.node_resource_group_id
  role_definition_name = "AppGw for Containers Configuration Manager"
  principal_id         = azurerm_user_assigned_identity.alb_managed_identity.principal_id
}

// Delegate Network Contributor permission for join to association subnet:
resource "azurerm_role_assignment" "networkContribAssign" {
  scope                = azurerm_subnet.alb_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.alb_managed_identity.principal_id
}
