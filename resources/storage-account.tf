resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type

  # Security configuration
  public_network_access_enabled   = var.storage_public_access_enabled
  allow_nested_items_to_be_public = var.allow_blob_public_access

  # Network rules
  network_rules {
    default_action = var.storage_default_network_action
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}
