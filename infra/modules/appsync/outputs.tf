output "graphql_api_id" {
  value = aws_appsync_graphql_api.main.id
}

output "graphql_api_url" {
  value = aws_appsync_graphql_api.main.uris["GRAPHQL"]
}