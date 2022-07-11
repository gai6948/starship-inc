module "dynamodb_table_ship_orders" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "2.0.0"

  name     = "ship-orders"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
