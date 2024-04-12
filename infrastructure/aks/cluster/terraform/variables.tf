variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the cluster should be created."
}

variable "location" {
  type        = string
  description = "The location where the cluster should be created."
}

variable "aks_name" {
  type        = string
  description = "The name of the cluster to be created."
}

variable "aks_container_registry_sku" {
  type        = string
  description = "The selected resource offer level for the container registry used by the cluster."
}

variable "aks_admin_username" {
  type        = string
  description = "The name of the admin account created for the cluster."
}

variable "aks_vnet_name" {
  type        = string
  description = "The name of the virtual network containing the AKS cluster."
}

variable "node_pool_name" {
  type        = string
  description = "The name of the pool containing the VMs on which the cluster is deployed."
}

variable "node_pool_vm_size" {
  type        = string
  description = "The size of the VMs created to run the cluster."
}

variable "node_pool_count" {
  type        = number
  description = "The number of nodes created within the pool on which the cluster runs."
}

variable "network_plugin" {
  type        = string
  description = "The networking plugin used by the created cluster."
}

variable "network_load_balancer_sku" {
  type        = string
  description = "The selected resource offer level for the cluster's loadbalancer."
}

variable "network_vnet_address_space" {
  type        = list(string)
  description = "The address space for the VNET created for the cluster."
}

variable "network_subnet_address_prefixes" {
  type        = list(string)
  description = "The address prefixes for the subnet created for the cluster."
}

