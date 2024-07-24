output "resource_group_name" {
  value = azurerm_resource_group.solution_rg.name
}

output "workload_identity" {
  value = module.workload_identity.identity
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "app_config_id" {
  value = module.app_config.app_config_id
}