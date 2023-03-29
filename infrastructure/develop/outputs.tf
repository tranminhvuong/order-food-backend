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
  }
}
