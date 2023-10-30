variable "cosmosdb_account_name" {
  type        = string
  description = "CosmosDB Account to apply the role assignment to"
}

variable "cosmosdb_account_resource_group" {
  type        = string
  description = "Resource group of the CosmosDB Account"
}

variable "cosmosdb_account_role_definition" {
  type        = string
  description = "Role definition id to assign to the principal"
  default     = "00000000-0000-0000-0000-000000000002"
  validation {
    condition     = contains(["00000000-0000-0000-0000-000000000001", "00000000-0000-0000-0000-000000000002"], var.cosmosdb_account_role_definition)
    error_message = "Role must be Data Reader or Data Writer"
  }
}

variable "principal_id" {
  type        = string
  description = "Principal id to assign the role to"
}
