# Find Amazon Linux 2023 AMI (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Replace old data.template_file with modern templatefile()
# No "data template_file" block needed — REMOVE IT.

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = local.ec2_key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # NEW CORRECT USER DATA
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    bucket_name = aws_s3_bucket.photos.bucket
    web_port    = local.web_port
  })

  tags = {
    Name = "${local.name_prefix}-ec2"
  }
}

output "web_public_dns" {
  value = aws_instance.web.public_dns
}

output "web_url" {
  value = "http://${aws_instance.web.public_dns}:${local.web_port}"
}