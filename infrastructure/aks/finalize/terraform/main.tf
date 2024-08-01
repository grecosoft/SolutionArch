// Reference to the AKS cluster to deploy the microservice solution:
data "azurerm_kubernetes_cluster" "k8s" {
  name                = local.cluster_name
  resource_group_name = local.cluster_resource_group_name
}

# data "azurerm_subnet" "alb_subnet" {
#   name                 = "alb-subnet"
#   virtual_network_name = local.cluster_vnet_name
#   resource_group_name  = local.cluster_resource_group_name
# }

// Define the ApplicationLoadBalancer resource, specifying the subnet ID the Application Gateway for Containers
// association resource should deploy into. The association establishes connectivity from Application Gateway 
// for Containers to the defined subnet. 
# resource "kubernetes_manifest" "gateway-alb" {
#   manifest = {
#     "apiVersion" = "alb.networking.azure.io/v1"
#     "kind"       = "ApplicationLoadBalancer"
#     "metadata" = {
#       "name"      = "gateway-alb"
#       "namespace" = var.container_gateway_namespace
#     }
#     spec = {
#       associations = [data.azurerm_subnet.alb_subnet.id]
#     }
#   }
# }

// Storage classes define how to create an Azure file share. A storage account is automatically created in the 
// node resource group for use with the storage class to hold the Azure Files file share.
// https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision
resource "kubernetes_storage_class" "azure_file_storage" {
  metadata {
    name = "azure-file-storage"
  }
  storage_provisioner    = "file.csi.azure.com"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"
  parameters = {
    skuName = "Standard_LRS"
  }
  mount_options = ["dir_mode=0777", "file_mode=0777", "uid=0", "gid=0", "mfsymlinks", "cache=strict", "actimeo=30"]
}

// Adds controller allowing for integration with Azure app configuration.
resource "helm_release" "app-config-controller" {
  namespace        = "app-config-system"
  create_namespace = true
  name             = "app-config-controller"
  repository       = "oci://mcr.microsoft.com/azure-app-configuration/helmchart"
  chart            = "kubernetes-provider"
}