#!/bin/bash

export TF_VAR_storage_resource_group_name="Terraform"
export TF_VAR_state_storage_account_name="terraformstate06410"

terraform -chdir=cluster/terraform init \
 -backend-config="resource_group_name=${TF_VAR_storage_resource_group_name}" \
 -backend-config="storage_account_name=${TF_VAR_state_storage_account_name}"

terraform -chdir=cluster/terraform apply -auto-approve

# terraform -chdir=gateway/terraform init \
#   -backend-config="resource_group_name=${TF_VAR_storage_resource_group_name}" \
#   -backend-config="storage_account_name=${TF_VAR_state_storage_account_name}"

# terraform -chdir=gateway/terraform apply -auto-approve

terraform -chdir=finalize/terraform init \
  -backend-config="resource_group_name=${TF_VAR_storage_resource_group_name}" \
  -backend-config="storage_account_name=${TF_VAR_state_storage_account_name}"

terraform -chdir=finalize/terraform apply -auto-approve

az aks get-credentials --resource-group kube-cluster --name mscluster --overwrite-existing
