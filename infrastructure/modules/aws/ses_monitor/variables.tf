variable "aws_account_id" {
  type = string
}

variable "matching_types" {
  type = list(string)
}

variable "sns_topic_name" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_runtime" {
  type = string
}

variable "lambda_package_zip" {
  type = string
}

variable "ses_configuration_set_name" {
  type = string
}

variable "ses_event_destination_name" {
  type = string
}

variable "lambda_memory_size" {
  type    = number
  default = 128
}

variable "layers" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "vpc_subnet_ids" {
  type = list(string)
}

