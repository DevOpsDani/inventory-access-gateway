# Development environment configuration
aws_region  = "us-west-2"
environment = "dev"
project     = "inventory-access-gateway"

# Cognito configuration
user_pool_name     = "inventory-gateway-users-dev"
user_pool_domain   = "inventory-gateway-auth-dev"
client_name        = "inventory-gateway-client-dev"
cognito_user_group = "example-client-tenant-dev"

# DynamoDB settings
table_name = "inventory-gateway-db-table"

# AppSync settings
api_name = "inventory-gateway-appsync"

# Security settings
enable_mfa = false

password_policy = {
  minimum_length    = 8
  require_lowercase = true
  require_numbers   = true
  require_symbols   = false # Less strict for dev
  require_uppercase = true
}

tags = {
  Environment = "dev"
  Project     = "inventory-access-gateway"
  ManagedBy   = "terraform"
  Owner       = "DevOps"
  CostCenter  = "development"
}