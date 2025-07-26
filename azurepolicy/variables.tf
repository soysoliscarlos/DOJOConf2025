variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "policy_resource_group_name" {
  description = "Name of the resource group for policy management"
  type        = string
  default     = "rg-policy-management"
}

variable "location" {
  description = "Azure region for policy assignment"
  type        = string
  default     = "East US"
}

variable "policy_name" {
  description = "Base name for the Azure Policy"
  type        = string
  default     = "disable-storage-public-access"
}

variable "policy_effect" {
  description = "Effect of the Azure Policy"
  type        = string
  default     = "DeployIfNotExists"
  validation {
    condition     = contains(["Audit", "Deny", "DeployIfNotExists", "Disabled"], var.policy_effect)
    error_message = "Policy effect must be one of: Audit, Deny, DeployIfNotExists, Disabled."
  }
}

variable "policy_exclusions" {
  description = "List of resource IDs to exclude from policy assignment"
  type        = list(string)
  default     = []
}

variable "enable_remediation" {
  description = "Whether to enable role assignment for remediation (manual trigger required)"
  type        = bool
  default     = false
}

variable "remediation_locations" {
  description = "List of locations to include in remediation (for reference only)"
  type        = list(string)
  default     = ["East US", "West US 2", "Central US"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "DOJO-Security-Policy"
    Owner       = "Security-Team"
    Purpose     = "Storage-Security"
  }
}
