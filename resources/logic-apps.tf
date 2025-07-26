# Logic App Workflow for Storage Account Security Automation
resource "azurerm_logic_app_workflow" "main" {
  name                = var.logic_app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"

  workflow_parameters = {
    "$connections" = jsonencode({
      type         = "Object"
      defaultValue = {}
    })
    "logging_webhook_url" = jsonencode({
      type         = "String"
      defaultValue = var.logging_webhook_url
    })
    "alert_webhook_url" = jsonencode({
      type         = "String"
      defaultValue = var.alert_webhook_url
    })
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Logic App Trigger - Recurrence (Every Hour)
resource "azurerm_logic_app_trigger_recurrence" "recurrencia" {
  name         = "Recurrencia"
  logic_app_id = azurerm_logic_app_workflow.main.id

  frequency = "Minute"
  interval  = 1
}

# Logic App Action - List Storage Accounts
resource "azurerm_logic_app_action_custom" "listar_storage_accounts" {
  name         = "Listar_Storage_Accounts"
  logic_app_id = azurerm_logic_app_workflow.main.id

  body = jsonencode({
    type = "Http"
    inputs = {
      method = "GET"
      uri    = "https://management.azure.com/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Storage/storageAccounts?api-version=2023-01-01"
      headers = {
        "Content-Type" = "application/json"
      }
      authentication = {
        type     = "ManagedServiceIdentity"
        audience = "https://management.azure.com/"
      }
    }
    runAfter = {}
  })

  depends_on = [azurerm_logic_app_trigger_recurrence.recurrencia]
}

# Logic App Action - Parse JSON for Storage Accounts
resource "azurerm_logic_app_action_custom" "parse_json_storage" {
  name         = "Parse_JSON_Storage"
  logic_app_id = azurerm_logic_app_workflow.main.id

  body = jsonencode({
    type = "ParseJson"
    inputs = {
      content = "@body('Listar_Storage_Accounts')"
      schema = {
        type = "object"
        properties = {
          value = {
            type = "array"
            items = {
              type = "object"
              properties = {
                id = {
                  type = "string"
                }
                name = {
                  type = "string"
                }
                properties = {
                  type = "object"
                  properties = {
                    allowBlobPublicAccess = {
                      type = "boolean"
                    }
                    publicNetworkAccess = {
                      type = "string"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    runAfter = {
      "Listar_Storage_Accounts" = ["Succeeded"]
    }
  })

  depends_on = [azurerm_logic_app_action_custom.listar_storage_accounts]
}

# Logic App Action - For Each Storage Account
resource "azurerm_logic_app_action_custom" "for_each_storage" {
  name         = "For_Each_Storage"
  logic_app_id = azurerm_logic_app_workflow.main.id

  body = jsonencode({
    type    = "Foreach"
    foreach = "@body('Parse_JSON_Storage')?['value']"
    actions = {
      "Condition_Check_Public_Access" = {
        type = "If"
        expression = {
          or = [
            {
              equals = [
                "@coalesce(items('For_Each_Storage')?['properties']?['allowBlobPublicAccess'], false)",
                true
              ]
            },
            {
              equals = [
                "@coalesce(items('For_Each_Storage')?['properties']?['publicNetworkAccess'], 'Disabled')",
                "Enabled"
              ]
            }
          ]
        }
        actions = {
          "Deshabilitar_Public_Access" = {
            type = "Http"
            inputs = {
              uri = "@{concat('https://management.azure.com', items('For_Each_Storage')?['id'], '?api-version=2023-01-01')}"

              method = "PATCH"
              headers = {
                "Content-Type" = "application/json"
              }
              body = {
                properties = {
                  publicNetworkAccess   = "Disabled"
                  allowBlobPublicAccess = false
                }
              }
              authentication = {
                type     = "ManagedServiceIdentity"
                audience = "https://management.azure.com/"
              }
              retryPolicy = {
                type     = "exponential"
                count    = 3
                interval = "PT10S"
              }
            }
          }
        }
        else = {
          actions = {
          }
        }
      }
    }
    runAfter = {
      "Parse_JSON_Storage" = ["Succeeded"]
    }
  })

  depends_on = [azurerm_logic_app_action_custom.parse_json_storage]
}



















# Role Assignment for Logic App to modify Storage Accounts
resource "azurerm_role_assignment" "logic_app_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.main.identity[0].principal_id

  depends_on = [azurerm_logic_app_workflow.main]
}
