locals {
  project     = "gps"
  environment = "common"

  vpc = {
    cidr            = "10.10.0.0/16"
    public_subnets  = ["10.10.0.0/19", "10.10.32.0/19", "10.10.64.0/19"]
    private_subnets = ["10.10.128.0/19", "10.10.160.0/19", "10.10.192.0/19"]
  }
}


module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  name                   = "${local.project}-${local.environment}"
  cidr                   = local.vpc.cidr
  azs                    = data.aws_availability_zones.available.names
  public_subnets         = local.vpc.public_subnets
  private_subnets        = local.vpc.private_subnets
  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
}
