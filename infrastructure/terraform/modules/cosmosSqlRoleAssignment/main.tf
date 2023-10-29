locals {
  role_assignment_id = guid(var.cosmosdb_account_role_definition, var.principal_id, azurerm_cosmosdb_account.cosmosdb_account.id)
}
data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.cosmosdb_account_resource_group
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_sql_assignment" {
  name                = local.role_assignment_id
  resource_group_name = var.cosmosdb_account_resource_group
  account_name        = var.cosmosdb_account_name
  role_definition_id  = var.cosmosdb_account_role_definition
  principal_id        = var.principal_id
  scope               = data.azurerm_cosmosdb_account.cosmosdb_account
}