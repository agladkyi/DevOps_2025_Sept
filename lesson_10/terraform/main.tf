terraform {
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
  region = "eu-west-3"
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.test_t3_micro.public_ip
}

output "instance_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_instance.test_t3_micro.public_dns
}

resource "aws_instance" "test_t3_micro" {
  ami                    = "ami-017f16157e7148709" # Amazon Linux 2023 for EU
  instance_type          = "t3.micro"              # Free tier
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  user_data              = <<-EOF
    #!/bin/bash
    sudo dnf update
    sudo dnf install -y httpd
    sudo systemctl start httpd.service
    sudo systemctl enable httpd.service
    sudo bash -c 'cat > /var/www/html/index.html' <<EOF_HTML
    <!DOCTYPE html>
    <html>
    <head>
    <style>
      body {
        background-color: #A1B0FF;
        text-align: center;
      }
    </style>
    </head>
    <body>
      <h1>Hello, Team.</h1>
      <h1>Welcome to server 1!</h1>
    </body>
    </html>
    EOF_HTML
  EOF
  tags = {
    Name = "HelloWorld Server"
  }
}

resource "random_pet" "sg" {}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 22
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
