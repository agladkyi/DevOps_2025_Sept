terraform {
  backend "s3" {
    bucket         = "pasv-course-gladkyitfproject-tf-state" # REPLACE WITH YOUR BUCKET NAME
    key            = "main/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5"
    }
  }
  required_version = ">= 1.8"
}

provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = "MyApplication_backend"
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "test_t3_micro" {
<<<<<<< HEAD
  count = var.number_of_instances

  ami                    = "ami-0bdd88bd06d16ba03" # Amazon Linux 2023
=======
  ami                    = "ami-017f16157e7148709" # Amazon Linux 2023
>>>>>>> 98c435a (home work / lesson 11 - 12)
  instance_type          = "t3.micro"              # Free tier
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  user_data              = file("${path.module}/user_data.sh")
  count                  = var.instance_count
  
  tags = merge(
    local.common_tags,
    {
      Name = "HelloWorld Server-$(count.index)"
    }
  )

  depends_on = [aws_security_group.web-sg]
}

resource "random_pet" "sg" {}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # значит "все"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
<<<<<<< HEAD
  value       = [for instance in aws_instance.test_t3_micro : instance.public_ip]
=======
  value = [for instance in aws_instance.test_t3_micro : instance.public_ip]
>>>>>>> 98c435a (home work / lesson 11 - 12)
}

output "instance_public_dns" {
  description = "The public DNS of the EC2 instance"
<<<<<<< HEAD
  value       = [for instance in aws_instance.test_t3_micro : instance.public_dns]
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
=======
  value = [for instance in aws_instance.test_t3_micro : instance.public_dns]
>>>>>>> 98c435a (home work / lesson 11 - 12)
}
