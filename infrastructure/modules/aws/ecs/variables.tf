variable "cluster_name" {
  type = string
}

variable "ecs_task_role_name" {
  type = string
}

variable "task_name" {
  type = string
}

variable "retention_in_days" {
  type = number
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

variable "fargate_cpu" {
  type    = number
  default = 512
}

variable "fargate_memory" {
  type    = number
  default = 1024
}


variable "repository_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "port" {
  type    = number
  default = null
}

variable "cluster_id" {
  type = string
}

variable "target_group_arn" {
  type    = string
  default = ""
}

variable "http_tcp_listener_arn" {
  type    = string
  default = ""
}

variable "schedule_task" {
  type    = number
  default = 0
}

variable "app_environments_vars" {
  type        = list(map(string))
  default     = []
}


variable "app_environments_vars_normal" {
  type        = list(map(string))
  default     = []
}

