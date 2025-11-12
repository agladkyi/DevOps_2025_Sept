terraform {
  backend "s3" {
    bucket         = "pasv-course-gladkyitfproject-tf-state"
    key            = "main/demo_terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_version = ">= 1.8"
}

provider "aws" {
  region = "eu-west-3"
}

module "ec2" {
  source = "./ec2"

  environment         = var.env
  number_of_instances = var.ni
}

variable "env" {
  description = "Environment name tag value"
  type        = string
}

variable "ni" {
  description = "Number of istances to create"
  type        = number
}

output "ec2_instance_ids" {
  value = module.ec2.instance_ids
}

output "ec2_public_ips" {
  value = module.ec2.public_ips
}