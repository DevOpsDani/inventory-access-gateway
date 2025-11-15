resource "aws_appsync_graphql_api" "main" {
  name                = var.api_name
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  user_pool_config {
    user_pool_id    = var.user_pool_id
    aws_region      = var.aws_region
    default_action  = "ALLOW"
  }

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.appsync_role.arn
    field_log_level          = "ERROR"
    exclude_verbose_content  = true
  }

  schema = file("${path.module}/schema.graphql")
}

resource "aws_iam_role" "appsync_role" {
  name = "${var.api_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "appsync.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "logging_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = aws_iam_role.appsync_role.name
}

resource "aws_iam_role_policy" "appsync_dynamodb_policy" {
  role = aws_iam_role.appsync_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:Query", "dynamodb:Scan", "dynamodb:GetItem", "dynamodb:PutItem"]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_appsync_datasource" "dynamodb" {
  api_id           = aws_appsync_graphql_api.main.id
  name             = "DynamoDBTable"
  type             = "AMAZON_DYNAMODB"
  service_role_arn = aws_iam_role.appsync_role.arn

  dynamodb_config {
    table_name = var.dynamodb_table_name
  }
}

resource "aws_appsync_resolver" "query_items" {
  api_id      = aws_appsync_graphql_api.main.id
  type        = "Query"
  field       = "getItems"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template  = file("${path.module}/resolvers/getItems.vtl")
  response_template = file("${path.module}/resolvers/response.vtl")
}

# Resolver for getting a specific item by ID
resource "aws_appsync_resolver" "query_item" {
  api_id      = aws_appsync_graphql_api.main.id
  type        = "Query"
  field       = "getItem"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template  = file("${path.module}/resolvers/getItem.vtl")
  response_template = file("${path.module}/resolvers/getItemResponse.vtl")
}