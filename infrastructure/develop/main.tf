# Common
locals {
  aws_account_id           = var.aws_account_id
  aws_region               = var.aws_region
  aws_image_registry       = "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com"
  project                  = var.project
  environment              = var.environment
  vpc_id                   = var.vpc_id
  allow_security_group_ids = var.allow_security_group_ids

  # Network
  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids

  db_port           = var.db_port
  db_timezone       = var.db_timezone
  env_value_default = var.env_value_default
}

locals {
  instance_class          = "db.t3.small"
  instance_amount         = var.instance_amount
  backup_retention_period = 35
  deletion_protection     = false
  master_username         = "master"
}

#--------------------------------------------------------------
# Start Security Group (SG)
#--------------------------------------------------------------
module "security_group" {
  source                   = "../modules/aws/security_group"
  vpc_id                   = local.vpc_id
  alb_sg_name              = "${local.project}-${local.environment}-alb"
  common_sg_name           = "${local.project}-${local.environment}-common"
  allow_security_group_ids = []
}

#--------------------------------------------------------------
# Start ECS Cluster
#--------------------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${local.project}-${local.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#--------------------------------------------------------------
# Start environment variables
#--------------------------------------------------------------

resource "aws_ssm_parameter" "env_cors" {
  name        = "/${local.project}/${local.environment}/fastapi/cors/origins"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.env_cors_default
}
resource "aws_ssm_parameter" "env_aws_secret_key" {
  name        = "/${local.project}/${local.environment}/fastapi/aws_secret_key"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.env_aws_secret_key
}
resource "aws_ssm_parameter" "env_aws_access_key" {
  name        = "/${local.project}/${local.environment}/fastapi/aws_access_key"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.env_aws_access_key
}
resource "aws_ssm_parameter" "env_aws_region" {
  name        = "/${local.project}/${local.environment}/fastapi/aws_region"
  description = "The parameter description"
  type        = "SecureString"
  value       = local.aws_region
}

# resource "aws_ssm_parameter" "env_bucket_name" {
#   name        = "/${local.project}/${local.environment}/fastapi/bucket_name"
#   description = "The parameter description"
#   type        = "SecureString"
#   value       = aws_s3_bucket.order_food_storage.bucket
# }

#--------------------------------------------------------------
# Start order_food API
#--------------------------------------------------------------
module "order_food_develop_alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "~> 6.0"
  name                       = "${local.project}-${local.environment}-alb"
  load_balancer_type         = "application"
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids
  enable_deletion_protection = false
  security_groups            = module.security_group.ids
  tags = {
    project = local.project
    env     = local.environment
  }

  target_groups = [
    {
      name               = "${local.project}-${local.environment}-api"
      backend_protocol   = "HTTP"
      backend_port       = 3000
      target_type        = "ip"
      target_group_index = 0
      health_check = {
        enabled             = true
        interval            = 300
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}
module "order_food_api_ecs" {
  source                = "../modules/aws/ecs"
  cluster_name          = aws_ecs_cluster.main.name
  cluster_id            = aws_ecs_cluster.main.id
  ecs_task_role_name    = "${local.project}-${local.environment}-ecs-api-task-execution"
  task_name             = "api"
  retention_in_days     = 30
  environment           = local.environment
  project               = local.project
  security_groups       = [module.security_group.common_id]
  subnet_ids            = local.private_subnet_ids
  port                  = 3000
  fargate_cpu           = 512
  fargate_memory        = 1024
  repository_name       = "${local.aws_image_registry}/${local.project}/${local.environment}/api"
  image_tag             = ":latest"
  target_group_arn      = module.order_food_develop_alb.target_group_arns[0]
  http_tcp_listener_arn = module.order_food_develop_alb.http_tcp_listener_arns[0]
  aws_region            = local.aws_region
  app_environments_vars = [
    { "name" = "BACKEND_CORS_ORIGINS", "valueFrom" = aws_ssm_parameter.env_cors.arn },
    { "name" = "AWS_ACCESS_KEY_ID", "valueFrom" = aws_ssm_parameter.env_aws_access_key.arn },
    { "name" = "AWS_SECRET_ACCESS_KEY", "valueFrom" = aws_ssm_parameter.env_aws_secret_key.arn },
    { "name" = "AWS_DEFAULT_REGION", "valueFrom" = aws_ssm_parameter.env_aws_region.arn },
    # { "name" = "BUCKET_NAME", "valueFrom" = aws_ssm_parameter.env_bucket_name.arn }
  ]
}

module "order_food_api_ecr" {
  source          = "../modules/aws/ecr"
  repository_name = "${local.project}/${local.environment}/api"
  keep_last_image = 3
}

#--------------------------------------------------------------
# CloudFront
#--------------------------------------------------------------
module "order_food_api_cloudfront" {
  source      = "../modules/aws/cloudfront"
  domain_name = module.order_food_develop_alb.lb_dns_name
  project     = local.project
  environment = local.environment
}




# resource "aws_s3_bucket" "order_food_storage" {
#   bucket = "${local.project}-${local.environment}-storage"
# }
# resource "aws_s3_bucket_acl" "order_food_storage_bucket_acl" {
#   bucket = aws_s3_bucket.order_food_storage.id
#   acl    = "public-read"
# }
# resource "aws_s3_bucket_cors_configuration" "order_food_storage_bucket_cors" {
#   bucket = aws_s3_bucket.order_food_storage.id

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
#     allowed_origins = ["*"]
#     max_age_seconds = 3000
#   }
# }
