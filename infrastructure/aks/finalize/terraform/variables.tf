// State Storage Variables:
variable "storage_resource_group_name" {
  type = string
}

variable "state_storage_account_name" {
  type = string
}

// Custer Finalize Variables:
variable "container_gateway_namespace" {
  type        = string
  description = "The Kubernetes namespace in which the controller will be installed."
}

