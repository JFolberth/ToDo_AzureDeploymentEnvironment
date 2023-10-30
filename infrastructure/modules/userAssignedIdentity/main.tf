resource "azurerm_user_assigned_identity" "uid" {
  location            = var.user_assigned_identity_location
  name                = "uid-${var.user_assigned_identity_name}"
  resource_group_name = var.resource_group_name
  tags = {
    Language = var.language
  }
}