solution = {
  cluster_resource_group = "[nf:aks-resource-group]"
  cluster_name           = "[nf:aks-name]"
  registry_name          = "[nf:arc-name]"
  environment            = "stg"
  name                   = "SolutionName"
  location               = "eastus"
  keyvault = {
    sku                        = "standard"
    soft_delete_retention_days = 7
    purge_protection_enabled   = true
  }
  appconfig = {
    namespace = "app-config-system"
  }
}
//-#if (useGitHub)
  github_account         = "[nf:github-account]"
//-#endif