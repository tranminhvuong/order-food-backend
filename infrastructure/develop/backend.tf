terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10"
    }
  }

  backend "s3" {
    bucket  = "order-food-backend-tfstate"
    region  = "ap-northeast-1"
    key     = "develop/order-food/terraform.tfstate"
    profile = "vscode"
    encrypt = true
  }
}
