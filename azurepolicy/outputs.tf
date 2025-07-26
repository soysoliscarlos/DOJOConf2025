output "policy_definition_id" {
  description = "ID of the storage public access policy definition"
  value       = azurerm_policy_definition.disable_storage_public_access.id
}

output "policy_definition_name" {
  description = "Name of the storage public access policy definition"
  value       = azurerm_policy_definition.disable_storage_public_access.name
}

output "policy_initiative_id" {
  description = "ID of the storage security initiative"
  value       = azurerm_policy_set_definition.storage_security_initiative.id
}

output "policy_assignment_id" {
  description = "ID of the policy assignment"
  value       = azurerm_subscription_policy_assignment.storage_security.id
}

output "policy_assignment_identity_principal_id" {
  description = "Principal ID of the policy assignment managed identity"
  value       = azurerm_subscription_policy_assignment.storage_security.identity[0].principal_id
}

output "subscription_id" {
  description = "Target subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

output "manual_remediation_command" {
  description = "Azure CLI command to trigger manual remediation"
  value       = "az policy remediation create --name \"storage-remediation-${formatdate("YYYY-MM-DD", timestamp())}\" --policy-assignment \"${azurerm_subscription_policy_assignment.storage_security.id}\""
}
