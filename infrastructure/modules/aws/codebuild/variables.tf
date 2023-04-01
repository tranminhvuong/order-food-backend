variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "build_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "account_id" {
  type = string
}

variable "github_source" {
  type = string
}

variable "region" {
  type = string
}

variable "aws_ecr_registry" {
  type = string
}

variable "aws_ecr_repository" {
  type = string
}

variable "aws_ecs_container_name" {
  type = string
}

variable "aws_ecs_task_name" {
  type = string
}


variable "codepipeline_bucket" {
  type = string
}

variable "bucket_arn" {
  type = string
}
