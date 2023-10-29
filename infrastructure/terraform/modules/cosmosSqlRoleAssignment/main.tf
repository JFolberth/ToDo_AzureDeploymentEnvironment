
resource "random_uuid" "role_assignment_id" {
}
data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.cosmosdb_account_resource_group
}

data "azurerm_cosmosdb_sql_role_definition" "cosmosdb_role_definition" {
  resource_group_name = var.cosmosdb_account_resource_group
  account_name        = var.cosmosdb_account_name
  role_definition_id  = var.cosmosdb_account_role_definition
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_sql_assignment" {
  name                = random_uuid.role_assignment_id.result
  resource_group_name = var.cosmosdb_account_resource_group
  account_name        = var.cosmosdb_account_name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.cosmosdb_role_definition.id
  principal_id        = var.principal_id
  scope               = data.azurerm_cosmosdb_account.cosmosdb_account.id
}