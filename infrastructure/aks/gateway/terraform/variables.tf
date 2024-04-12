// State Storage Variables:
variable "storage_resource_group_name" {
  type = string
}

variable "state_storage_account_name" {
  type = string
}

// Cluster Gateway Variables:
variable "identity_resource_name" {
  type        = string
  description = "The name of identity created and used by Gateway for Containers."
}

variable "container_gateway_namespace" {
  type        = string
  description = "The Kubernetes namespace in which the controller will be installed."
}

variable "alb_subnet_address_prefixes" {
  type        = list(string)
  description = "The address prefixes assocated with the sub net created for the application load balancer."
  default     = ["10.225.0.0/24"]
}
