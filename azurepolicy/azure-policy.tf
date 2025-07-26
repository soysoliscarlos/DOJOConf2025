# Azure Policy Definition - Disable Storage Account Public Network Access
resource "azurerm_policy_definition" "disable_storage_public_access" {
  name         = var.policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Disable Storage Account Public Network Access"
  description  = "This policy ensures that Storage Accounts have public network access disabled for enhanced security"

  metadata = jsonencode({
    category = "Storage"
    version  = "1.0.0"
    source   = "DOJO-Security-Automation"
  })

  parameters = jsonencode({
    effect = {
      type = "String"
      metadata = {
        displayName = "Effect"
        description = "The effect of the policy. DeployIfNotExists will remediate non-compliant resources"
      }
      allowedValues = ["Audit", "Deny", "DeployIfNotExists", "Disabled"]
      defaultValue  = var.policy_effect
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          anyOf = [
            {
              field     = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
              notEquals = "Disabled"
            },
            {
              field  = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
              exists = "false"
            }
          ]
        }
      ]
    }
    then = {
      effect = "[parameters('effect')]"
      details = {
        type = "Microsoft.Storage/storageAccounts"
        name = "[field('name')]"
        existenceCondition = {
          field  = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
          equals = "Disabled"
        }
        roleDefinitionIds = [
          "/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab"
        ]
        deployment = {
          properties = {
            mode = "incremental"
            template = {
              "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
              contentVersion = "1.0.0.0"
              parameters = {
                storageAccountName = {
                  type = "string"
                }
                location = {
                  type = "string"
                }
              }
              resources = [
                {
                  type       = "Microsoft.Storage/storageAccounts"
                  apiVersion = "2023-01-01"
                  name       = "[parameters('storageAccountName')]"
                  location   = "[parameters('location')]"
                  properties = {
                    publicNetworkAccess   = "Disabled"
                    allowBlobPublicAccess = false
                  }
                }
              ]
            }
            parameters = {
              storageAccountName = {
                value = "[field('name')]"
              }
              location = {
                value = "[field('location')]"
              }
            }
          }
        }
      }
    }
  })
}

# Azure Policy Definition - Audit Storage Account Public Blob Access
resource "azurerm_policy_definition" "audit_storage_blob_public_access" {
  name         = "${var.policy_name}-blob-audit"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Audit Storage Account Public Blob Access"
  description  = "This policy audits Storage Accounts that allow public blob access"

  metadata = jsonencode({
    category = "Storage"
    version  = "1.0.0"
    source   = "DOJO-Security-Automation"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field  = "Microsoft.Storage/storageAccounts/allowBlobPublicAccess"
          equals = true
        }
      ]
    }
    then = {
      effect = "Audit"
    }
  })
}

# Policy Set Definition (Initiative)
resource "azurerm_policy_set_definition" "storage_security_initiative" {
  name         = "${var.policy_name}-initiative"
  policy_type  = "Custom"
  display_name = "Storage Account Security Initiative"
  description  = "Collection of policies to secure Azure Storage Accounts"

  metadata = jsonencode({
    category = "Storage"
    version  = "1.0.0"
    source   = "DOJO-Security-Automation"
  })

  parameters = jsonencode({
    effect = {
      type = "String"
      metadata = {
        displayName = "Effect for Storage Network Access Policy"
        description = "The effect of the storage network access policy"
      }
      allowedValues = ["Audit", "Deny", "DeployIfNotExists", "Disabled"]
      defaultValue  = var.policy_effect
    }
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.disable_storage_public_access.id
    parameter_values = jsonencode({
      effect = {
        value = "[parameters('effect')]"
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.audit_storage_blob_public_access.id
  }
}

# Policy Assignment at Subscription Level
resource "azurerm_subscription_policy_assignment" "storage_security" {
  name                 = "${var.policy_name}-subscription"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.storage_security_initiative.id
  display_name         = "Storage Account Security Policy Assignment"
  description          = "Assignment of storage security policies at subscription level"
  location             = var.location

  parameters = jsonencode({
    effect = {
      value = var.policy_effect
    }
  })

  identity {
    type = "SystemAssigned"
  }

  not_scopes = var.policy_exclusions
}

# Role Assignment for Policy Remediation
resource "azurerm_role_assignment" "policy_remediation" {
  count                = var.policy_effect == "DeployIfNotExists" ? 1 : 0
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_subscription_policy_assignment.storage_security.identity[0].principal_id

  depends_on = [azurerm_subscription_policy_assignment.storage_security]
}

# Note: azurerm_policy_remediation is not supported in this provider version
# Manual remediation can be triggered via Azure CLI:
# az policy remediation create --name "storage-remediation" --policy-assignment "/subscriptions/{sub-id}/providers/Microsoft.Authorization/policyAssignments/{assignment-name}"
