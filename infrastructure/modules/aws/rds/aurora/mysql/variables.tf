variable "cluster_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "engine_version" {
  type    = string
  default = "5.7.12"
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "instance_class" {
  type = string
}

variable "instance_amount" {
  type = number
}

variable "master_username" {
  type = string
}

variable "backup_retention_period" {
  type    = number
  default = 35
}

variable "rds_credentials_name" {
  type = string
}

variable "project" {
  type = string
}
