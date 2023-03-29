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
  default = "12.7"
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
