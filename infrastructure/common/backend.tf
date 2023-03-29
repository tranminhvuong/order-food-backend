terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10.0"
    }
  }

  backend "s3" {
    bucket  = "gps-be-tr-tfstate"
    region  = "ap-northeast-1"
    key     = "common/gps-be-tr/terraform.tfstate"
    profile = "vscode"
    encrypt = true
  }
}
