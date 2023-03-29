output "main" {
  value = {
    network = {
      vpc_id          = module.vpc.vpc_id
      private_subnets = module.vpc.private_subnets
      public_subnets  = module.vpc.public_subnets

    }
  }
}
