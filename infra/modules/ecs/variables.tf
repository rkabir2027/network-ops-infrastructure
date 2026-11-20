
variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "https_listener_arn" {
  type = string
}

variable "container_image" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}
