terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Call the Cognito module
module "cognito" {
  source = "./modules/cognito"

  # Cognito User Pool configuration
  user_pool_name     = var.user_pool_name
  user_pool_domain   = var.user_pool_domain
  client_name        = var.client_name
  cognito_user_group = var.cognito_user_group

  # Environment and tagging
  environment = var.environment
  project     = var.project

  # User pool policies
  password_policy = var.password_policy

  # MFA settings
  enable_mfa = var.enable_mfa

  tags = var.tags
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.table_name
}

module "appsync" {
  source              = "./modules/appsync"
  api_name            = var.api_name
  user_pool_id        = module.cognito.user_pool_id
  region              = var.aws_region
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  callback_urls       = "callback-url.com"
}