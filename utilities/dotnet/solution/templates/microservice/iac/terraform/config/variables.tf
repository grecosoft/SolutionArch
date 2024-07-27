variable "subscriptionId" {
  type        = string
  description = "The Azure subscription of the solution."
}

variable "tenantid" {
  type        = string
  description = "The Azure tenant of the solution."
}


variable "service_name" {
  type = string
}

variable "resource_group_name" {
    type = string 
}

variable storage_account_name {
   type = string 
}

variable container_name {
   type = string 
}