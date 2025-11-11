variable "table_name" {
  description = "Table Name"
  type        = string
}

variable "billing_mode" { 
    default = "PAY_PER_REQUEST" 
    type = string
}
