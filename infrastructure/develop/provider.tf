provider "aws" {
  region     = "ap-northeast-1"
  sts_region = "ap-northeast-1"
  profile    = "vscode"

  default_tags {
    tags = {
      Project    = "order_food"
      Env        = "develop"
      Repository = "https://github.com/tranminhvuong/order-food-backend"
    }
  }
}
