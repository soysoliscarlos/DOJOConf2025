variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-dojo-security-automation"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "logic_app_name" {
  description = "Name of the Logic App"
  type        = string
  default     = "logic-dojo-security"
}

variable "policy_name" {
  description = "Name of the Azure Policy"
  type        = string
  default     = "require-resource-tags"
}

variable "policy_effect" {
  description = "Effect of the Azure Policy (Audit, Deny, AuditIfNotExists)"
  type        = string
  default     = "Audit"
  validation {
    condition     = contains(["Audit", "Deny", "AuditIfNotExists"], var.policy_effect)
    error_message = "Policy effect must be one of: Audit, Deny, AuditIfNotExists."
  }
}

variable "required_tags" {
  description = "List of required tags for the policy"
  type        = list(string)
  default     = ["Environment", "Project", "Owner"]
}

variable "policy_resource_types" {
  description = "List of resource types to apply the policy to"
  type        = list(string)
  default = [
    "Microsoft.Compute/virtualMachines",
    "Microsoft.Storage/storageAccounts",
    "Microsoft.Network/virtualNetworks",
    "Microsoft.KeyVault/vaults"
  ]
}

variable "policy_exclusions" {
  description = "List of resource IDs to exclude from policy assignment"
  type        = list(string)
  default     = []
}

variable "alert_webhook_url" {
  description = "Webhook URL for sending alerts and summary reports"
  type        = string
  default     = "https://webhook.site/unique-id-for-alerts"
}

variable "logging_webhook_url" {
  description = "Webhook URL for logging compliance and remediation actions"
  type        = string
  default     = "https://webhook.site/unique-id-for-logs"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "DOJO-Security-Automation"
    Owner       = "Security-Team"
  }
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = null
}

# Storage Account Variables
variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "stdojosecurity001"
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters, lowercase letters and numbers only."
  }
}

variable "storage_account_tier" {
  description = "Tier of the storage account"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be either Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Replication type for the storage account"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Invalid replication type."
  }
}

variable "storage_public_access_enabled" {
  description = "Whether public network access is enabled for the storage account"
  type        = bool
  default     = false
}

variable "allow_blob_public_access" {
  description = "Whether to allow public access to blobs"
  type        = bool
  default     = false
}

variable "storage_default_network_action" {
  description = "Default network access rule"
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.storage_default_network_action)
    error_message = "Network action must be either Allow or Deny."
  }
}
