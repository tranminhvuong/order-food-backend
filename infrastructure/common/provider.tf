provider "aws" {
  region     = "ap-northeast-1"
  profile    = "vscode"

  default_tags {
    tags = {
      Project    = "gps-be-tr"
      Env        = "common"
      Repository = "https://github.com/HITSERIES-PINFALL/GPS-BE-TR"
    }
  }
}
