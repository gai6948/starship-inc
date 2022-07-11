terraform {
  backend "s3" {
    bucket         = "starship-inc-terraform-s3-backend-dev-may30"
    key            = "starship-inc-terraform-aws-state-dev"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

  }
  required_version = ">= 0.14"
}
