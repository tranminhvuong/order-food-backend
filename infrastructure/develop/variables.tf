variable "project" {
  type        = string
  description = "Project Name"
  default     = "gps"
}

variable "environment" {
  type        = string
  description = "VPC ID"
  default     = "develop"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "instance_amount" {
  type    = number
  default = 1
}

variable "allow_security_group_ids" {
  type = list(string)
}

variable "aws_account_id" {
  type        = string
  description = "aws_account_id"
}

variable "aws_region" {
  description = "aws region"
  default     = "ap-northeast-1"
}

variable "aws_image_registry" {
  type        = string
  description = "aws image registry"
  default     = ""
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List public subnets"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List private subnets"
}

variable "api_port" {
  type    = number
  default = 80
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "db_timezone" {
  type    = string
  default = "UTC"
}

variable "env_value_default" {
  type    = string
  default = "default"
}

variable "env_debug" {
  type    = string
  default = "True"
}

variable "env_cors_default" {
  type    = string
  default = "*"
}

variable "env_aws_access_key" {
  type    = string
  default = "test"
}

variable "env_aws_secret_key" {
  type    = string
  default = "test"
}

variable "github_source" {
  type = string
}

variable "codestar_connection_arn" {
  type    = string
  default = "arn:aws:codestar-connections:ap-southeast-1:715915800849:connection/3415d239-2bc9-49c3-b15c-b7caec0df181"
}

variable "full_repository_id" {
  type    = string
  default = "tranminhvuong/order-food-backend"
}
