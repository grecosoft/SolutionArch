locals {
  unique_postfix = lower(random_string.unique_postfix.result)
}

resource "random_string" "unique_postfix" {
  length  = 7
  special = false
}

// Create an Azure resource group to contain the solution's related resources:
resource "azurerm_resource_group" "solution_rg" {
  name     = "${var.solution.name}-${var.solution.environment}"
  location = var.solution.location
}

// Create a Kubernetes namespace to contain the solution's related resources:
resource "kubernetes_namespace" "solution_ns" {
  metadata {
    name = "${lower(var.solution.name)}-${var.solution.environment}"
  }
}

// Create workload identity for the solution.  This identity will be used to
// authenticate the Azure resources used by the solution.
module "workload_identity" {
  source          = "./modules/workload_identity"
  oidc_issuer_url = local.cluster_oidc_issuer_url
  resource_group  = azurerm_resource_group.solution_rg.name
  location        = azurerm_resource_group.solution_rg.location
  identity_name   = var.solution.name
  namespace       = kubernetes_namespace.solution_ns.metadata[0].name
}

//-- Create the Azure resources used by the solution and the associated
//   Kubernetes controller used to integrate the Azure resource for use
//   by solution defined services:
module "key_vault" {
  source                     = "./modules/key_vault"
  identity                   = module.workload_identity.identity
  resource_group             = azurerm_resource_group.solution_rg.name
  location                   = azurerm_resource_group.solution_rg.location
  name                       = "${var.solution.name}-secrets"
  unique_postfix             = local.unique_postfix
  sku                        = var.solution.keyvault.sku
  soft_delete_retention_days = var.solution.keyvault.soft_delete_retention_days
  purge_protection_enabled   = var.solution.keyvault.purge_protection_enabled
}

module "app_config" {
  source                  = "./modules/app_config"
  resource_group          = azurerm_resource_group.solution_rg.name
  resource_group_id       = azurerm_resource_group.solution_rg.id
  location                = azurerm_resource_group.solution_rg.location
  name                    = "${var.solution.name}-configs"
  unique_postfix          = local.unique_postfix
  identity                = module.workload_identity.identity
  cluster_oidc_issuer_url = local.cluster_oidc_issuer_url
  namespace               = var.solution.appconfig.namespace
  key_vault_key_id        = module.key_vault.key_vault_key_id
  depends_on              = [module.key_vault]
}

// Install helm charts to create resources used by the solution:
module "helm_installs" {
  source             = "./modules/helm_installs"
  solution_namespace = kubernetes_namespace.solution_ns.metadata[0].name
}

// Application Configuration Data required when deploying solution services.
// The templates/shared/deploy-service-pipeline.yml and ./github/workflows/shared-deploy-workflow.yml
// buid definitions reads these values from the app-configuration service for the environment being
// deployed to and passes them to the Helm chart when deploying the service to Kubernetes.
resource "azurerm_app_configuration_key" "SolutionTenantId" {
  configuration_store_id = module.app_config.app_config_id
  key                    = "SolutionTenantId"
  value                  = module.workload_identity.identity.tenant_id
}

resource "azurerm_app_configuration_key" "SolutionClientId" {
  configuration_store_id = module.app_config.app_config_id
  key                    = "SolutionClientId"
  value                  = module.workload_identity.identity.client_id
}

resource "azurerm_app_configuration_key" "SolutionAppConfigEndpoint" {
  configuration_store_id = module.app_config.app_config_id
  key                    = "SolutionAppConfigEndpoint"
  value                  = module.app_config.app_config_endpoint
}

resource "azurerm_app_configuration_key" "SolutionKeyVaultName" {
  configuration_store_id = module.app_config.app_config_id
  key                    = "SolutionKeyVaultName"
  value                  = module.key_vault.key_vault_name
}