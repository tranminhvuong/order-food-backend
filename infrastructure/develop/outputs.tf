output "main" {
  value = {
    network = {
      security_groups = {
        common = module.security_group.common_id
        alb    = module.security_group.alb_id
      }
    }
    target_groups = {
      # frontend = module.gps_develop_alb.target_group_arns
      api = module.order_food_develop_alb.target_group_arns
    }
    ecr = {
      # frontend = module.gps_frontend_ecr.repository_url
      api = module.order_food_api_ecr.repository_url
    }
    ecs = {
      cluster = aws_ecs_cluster.main
    }
    load_balancer = {
      domain_name = module.order_food_develop_alb.lb_dns_name
    }
    iot = {
      thing_arn       = module.order_food_iot_core.arn
      public_key      = module.order_food_iot_core.public_key
      private_key     = module.order_food_iot_core.private_key
      certificate_pem = module.order_food_iot_core.certificate_pem

    }
    cognito_identity_pool_id = module.order_food_cognito_identity_pool.identity_pool_id
  }
  sensitive = true
}
