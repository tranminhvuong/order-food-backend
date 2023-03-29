variable "cluster_arn" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "task_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}


variable "task_definition_exec_role_arn" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "task_count" {
  type = number
  default = 2
}
