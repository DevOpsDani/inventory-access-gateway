variable "user_pool_name" {
  description = "Name for the Cognito User Pool"
  type        = string
}

variable "user_pool_domain" {
  description = "Domain prefix for Cognito hosted UI"
  type        = string
}

variable "client_name" {
  description = "Name for the Cognito User Pool Client"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "cognito_user_group" {
  description = "Cognito user group name"
  type        = string
}

variable "enable_mfa" {
  description = "Enable MFA for user pool"
  type        = bool
  default     = false
}

variable "callback_urls" {
  description = "callback_urls"
  type        = string
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_numbers   = bool
    require_symbols   = bool
    require_uppercase = bool
  })
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}