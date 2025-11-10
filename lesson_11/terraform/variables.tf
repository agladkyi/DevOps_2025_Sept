variable "region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environment name tag value"
  type        = string
  default     = "dev"
}

variable "instance_count" {
  description = "Количество EC2 инстансов"
  type        = number
  default     = 3
}