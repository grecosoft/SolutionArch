variable "subscriptionId" {
  type        = string
  description = "The Azure subscription of the solution."
}

variable "tenantid" {
  type        = string
  description = "The Azure tenant of the solution."
}

variable "solution" {
  type = object({
    cluster_resource_group = string // Resource group containing the AKS cluster.
    cluster_name           = string // The name of the AKS cluster.
    registry_name          = string // Name of the registry the AKS cluster pulls images from.
    environment            = string // The environment short name associated with execution of configuration (dev, stg, prd...)
    name                   = string // The name of the solution used when creating named resources.
    location               = string // The location in which the resources should be created.
    github_account         = string // Set when using GitHub DevOps Actions to deploy solution.
    keyvault = object({
      sku                        = string
      soft_delete_retention_days = number
      purge_protection_enabled   = bool
    })
    appconfig = object({
      namespace = string // The Kubernetes namespace to deploy Azure AppConfig Provider.
    })
  })
}