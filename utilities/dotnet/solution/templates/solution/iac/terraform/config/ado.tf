// -----------------------------------------------------------------------
// Reference to the existing DevOps project and repostory associated with
// the solution.
// -----------------------------------------------------------------------
data "azuredevops_project" "solution_project" {
  name = var.solution.name
}

data "azuredevops_git_repository" "solution_repo" {
  project_id = data.azuredevops_project.solution_project.id
  name       = var.solution.name
}

// -----------------------------------------------------------------------
// Create application and service principal for federation
// -----------------------------------------------------------------------
resource "azuread_application" "ado_pipeline" {
  display_name = "ado-pipeline-${lower(var.solution.name)}-${var.solution.environment}"
}

resource "azuread_service_principal" "ado_pipeline_sp" {
  client_id    = azuread_application.ado_pipeline.client_id
  use_existing = true
}

resource "azurerm_role_assignment" "pipeline_role" {
  scope                = azurerm_resource_group.solution_rg.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.ado_pipeline_sp.object_id
}

resource "azuredevops_serviceendpoint_azurerm" "devops_endpoint" {
  project_id                             = data.azuredevops_project.solution_project.id
  service_endpoint_name                  = "ado-pipeline-${lower(var.solution.name)}"
  description                            = "Managed by Terraform"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  credentials {
    serviceprincipalid = azuread_service_principal.ado_pipeline_sp.client_id
  }
  azurerm_spn_tenantid      = var.tenantid
  azurerm_subscription_id   = var.subscriptionId
  azurerm_subscription_name = data.azurerm_subscription.subscription.display_name
}

resource "azuread_application_federated_identity_credential" "ado_federated_identity" {
  application_id = azuread_application.ado_pipeline.id
  display_name   = "AdoPipelineTasks"
  description    = "Allows ADO Pipeline tasks to have access to Azure Resources required for deployment."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = azuredevops_serviceendpoint_azurerm.devops_endpoint.workload_identity_federation_issuer
  subject        = azuredevops_serviceendpoint_azurerm.devops_endpoint.workload_identity_federation_subject
}

// -----------------------------------------------------------------------
// Azure resource roles for the federated service-principal, under which 
// the pipelines runs, required to build and deploy the solution.
// -----------------------------------------------------------------------
resource "azurerm_role_assignment" "AdoAcrPull" {
  principal_id                     = azuread_service_principal.ado_pipeline_sp.object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "AdoAcrPush" {
  principal_id                     = azuread_service_principal.ado_pipeline_sp.object_id
  role_definition_name             = "AcrPush"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "AdoAksContributor" {
  principal_id                     = azuread_service_principal.ado_pipeline_sp.object_id
  role_definition_name             = "Contributor"
  scope                            = data.azurerm_kubernetes_cluster.k8s.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "AdoAacReader" {
  principal_id                     = azuread_service_principal.ado_pipeline_sp.object_id
  role_definition_name             = "App Configuration Data Reader"
  scope                            = module.app_config.app_config_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "AdoAacContributor" {
  principal_id                     = azuread_service_principal.ado_pipeline_sp.object_id
  role_definition_name             = "Contributor"
  scope                            = module.app_config.app_config_id
  skip_service_principal_aad_check = true
}

// -----------------------------------------------------------------------
// Create DevOps variable group and populate with variables pertaining to
// the specific environment.  These variables are used by the pipeline
// when deploying to associated environment.
// -----------------------------------------------------------------------
resource "azuredevops_variable_group" "var_group" {
  project_id   = data.azuredevops_project.solution_project.id
  name         = var.solution.environment
  description  = "${var.solution.environment} environment group"
  allow_access = true

  variable {
    name  = "EnvAcrEndpoint"
    value = "${var.solution.registry_name}.azurecr.io"
  }

  variable {
    name  = "EnvAcrName"
    value = var.solution.registry_name
  }

  variable {
    name  = "EnvAksName"
    value = var.solution.cluster_name
  }

  variable {
    name  = "EnvAksResourceGroup"
    value = var.solution.cluster_resource_group
  }

  variable {
    name  = "EnvAppConfigEndpoint"
    value = module.app_config.app_config_endpoint
  }

  variable {
    name  = "EnvAppConfigName"
    value = module.app_config.app_config_name
  }
}

resource "azuredevops_environment" "environment" {
  project_id = data.azuredevops_project.solution_project.id
  name       = var.solution.environment
}

// -----------------------------------------------------------------------
// Create pipelines for the shared solution items:
// -----------------------------------------------------------------------
locals {
  solution_pipelines = [{
    name        = "SolutionName.Common"
    path_filter = "shared/src"
    }, {
    name        = "HelmCharts"
    path_filter = "shared/charts"
    }
  ]
}

resource "azuredevops_build_definition" "solution_builds" {
  for_each   = { for pipeline in local.solution_pipelines : pipeline.name => pipeline }
  project_id = data.azuredevops_project.solution_project.id
  name       = each.key

  ci_trigger {
    override {
      branch_filter {
        include = ["master"]
      }
      path_filter {
        include = [each.value.path_filter]
      }
    }
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.solution_repo.id
    branch_name = "refs/heads/master"
    yml_path    = "templates/${each.key}.yml"
  }
}

// -----------------------------------------------------------------------
// The solution project and repository are exposed for use by services
// from which the solution is comprised and reference by their specific
// service build definitions.
// -----------------------------------------------------------------------
output "solution_project_id" {
  value = data.azuredevops_project.solution_project.id
}

output "solution_repo_id" {
  value = data.azuredevops_git_repository.solution_repo.id
}