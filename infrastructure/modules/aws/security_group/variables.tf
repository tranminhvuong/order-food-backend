variable "vpc_id" {
  type = string
}

variable "alb_sg_name" {
  type = string
}

variable "common_sg_name" {
  type = string
}


variable "allow_security_group_ids" {
  type = list(string)
}
