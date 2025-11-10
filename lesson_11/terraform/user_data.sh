#!/bin/bash
sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html