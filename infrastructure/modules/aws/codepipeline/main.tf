locals {
  environment             = var.environment
  project                 = var.project
  bucket_arn              = var.bucket_arn
  bucket_name             = var.bucket_name
  codestar_connection_arn = var.codestar_connection_arn
  full_repository_id      = var.full_repository_id
  cluster_name            = var.cluster_name
  service_name            = var.service_name
}

data "aws_iam_policy_document" "codepipeline_policy_data" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*",
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [local.codestar_connection_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codepipeline:*"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codepipeline_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gps_codepipeline_role" {
  name               = "${local.project}-${local.environment}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role_policy.json
  inline_policy {
    name   = "${local.project}-${local.environment}-codepipeline-policy"
    policy = data.aws_iam_policy_document.codepipeline_policy_data.json
  }
}

resource "aws_codepipeline" "main" {
  name     = "${var.project}-${var.environment}-pipeline"
  role_arn = aws_iam_role.gps_codepipeline_role.arn
  artifact_store {
    location = local.bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = 1
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = local.codestar_connection_arn
        FullRepositoryId = local.full_repository_id
        BranchName       = local.environment
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = "${local.project}_${local.environment}"
      }

    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ClusterName = local.cluster_name
        ServiceName = local.service_name
      }
    }
  }
}
