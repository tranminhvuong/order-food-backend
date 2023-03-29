terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10.0"
    }
  }

  backend "s3" {
    bucket  = "order-food-backend-tfstate"
    region  = "ap-northeast-1"
    key     = "common/order-food-backend/terraform.tfstate"
    profile = "vscode"
    encrypt = true
  }
}
