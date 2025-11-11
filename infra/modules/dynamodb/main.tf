resource "aws_dynamodb_table" "main" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = "tenant"
  range_key      = "id"

  attribute {
    name = "tenant"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }
}
