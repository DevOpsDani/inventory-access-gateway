terraform {
  backend "s3" {
    bucket  = < S3 Bucket >
    key     = "inventory-gateway/cognito/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}