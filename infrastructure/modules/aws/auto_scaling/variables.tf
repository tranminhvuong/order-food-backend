variable "cluster_name" {
  type = string
}

variable "task_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 10
}

variable "scaling_up_adjustment" {
  type    = number
  default = 1
}

variable "scaling_down_adjustment" {
  type    = number
  default = -1
}

variable "cpu_high_threshold" {
  type    = string
  default = "85"
}

variable "cpu_low_threshold" {
  type    = string
  default = "10"
}
