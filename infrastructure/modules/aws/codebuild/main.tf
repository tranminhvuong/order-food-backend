locals {
  github_source          = var.github_source
  vpc_id                 = var.vpc_id
  build_subnets          = var.build_subnets
  aws_ecr_registry       = var.aws_ecr_registry
  aws_ecr_repository     = var.aws_ecr_repository
  region                 = var.region
  environment            = var.environment
  project                = var.project
  aws_ecs_container_name = var.aws_ecs_container_name
  aws_ecs_task_name      = var.aws_ecs_task_name
  account_id             = var.account_id
}

resource "aws_security_group" "order_food_codebuild_sg" {
  name   = "${local.project}-${local.environment}-codebuid-sg"
  vpc_id = local.vpc_id

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "codebuild_config_environment" {
  bucket = "${local.project}-${local.environment}-codebuild-config-environment"
}

resource "aws_s3_bucket_acl" "codebuild_config_environment_acl" {
  bucket = aws_s3_bucket.codebuild_config_environment.id
  acl    = "private"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    sid     = "TrustPolicyStatementThatAllowsEC2ServiceToAssumeTheAttachedRole"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${local.project}_${local.environment}_codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${var.region}:${local.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = [
        "arn:aws:ec2:ap-northeast-1:715915800849:subnet/subnet-08f6d526a5204c145",
        "arn:aws:ec2:ap-northeast-1:715915800849:subnet/subnet-011271d34de30ebed",
        "arn:aws:ec2:ap-northeast-1:715915800849:subnet/subnet-04a1b10795c0b4b07"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]
    resources = [
      "arn:aws:s3:::${var.codepipeline_bucket}",
      "arn:aws:s3:::${var.codepipeline_bucket}/*"
    ]
  }
}

resource "aws_iam_role_policy" "example" {
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "${local.project}_${local.environment}"
  description   = "${local.project}_${local.environment}_project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ECR_REPOSITORY"
      value = local.aws_ecr_repository
    }

    environment_variable {
      name  = "AWS_ECR_REGISTRY"
      value = local.aws_ecr_registry
    }

    environment_variable {
      name  = "TASK_NAME"
      value = local.aws_ecs_task_name
    }

    environment_variable {
      name  = "AWS_ECS_CONTAINER_NAME"
      value = local.aws_ecs_container_name
    }

    environment_variable {
      name  = "S3_CONFIG_BUCKET_URI"
      value = "${aws_s3_bucket.codebuild_config_environment.id}/${local.environment}/.env"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = local.region
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  source_version = local.environment

  tags = {
    Environment = "Test"
  }
}

