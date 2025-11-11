variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "inventory-access-gateway"
}

variable "callback_urls" {
  description = "callback_urls"
  type        = string
}

variable "user_pool_name" {
  description = "Name for the Cognito User Pool"
  type        = string
  default     = "inventory-gateway-users"
}

variable "user_pool_domain" {
  description = "Domain prefix for Cognito hosted UI"
  type        = string
  default     = "inventory-gateway-auth"
}

variable "cognito_user_group" {
  description = "Cognito user group name"
  type        = string
}

variable "client_name" {
  description = "Name for the Cognito User Pool Client"
  type        = string
  default     = "inventory-gateway-client"
}

variable "enable_mfa" {
  description = "Enable MFA for user pool"
  type        = bool
  default     = false
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
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}


variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "inventory-access-gateway"
    ManagedBy = "terraform"
    Owner     = "DevOps"
  }
}

variable "table_name" {
  description = "Table Name"
  type        = string
}

variable "api_name" {
  description = "Name of the AppSync API"
  type        = string
}
