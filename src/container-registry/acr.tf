resource "azurerm_container_registry" "acr" {
  name                = var.acrResourceName
  resource_group_name = azurerm_resource_group.rg.name
  location            = "westeurope"
  sku                 = "Standard"
  admin_enabled       = true
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.umi.id
    ]
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "acrPushRole" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = var.spnSparkObjectId
}
