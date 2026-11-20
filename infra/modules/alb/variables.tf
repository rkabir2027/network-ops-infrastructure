
variable "project_name" {
  description = "Project name for AWS resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}
