#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Terraform cloud
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available_zones" {}

data "aws_ami" "latest_linux" { #search latest amazon linux2 AMI
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

#--------Security Group-------------------------------------------------------------------------------------------------------------

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_security_group" "dynamic_sg" {
  name        = "Server_sg_${terraform.workspace}"
  description = "Security Group"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443"] #fill these ports in ingress.value
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Server_SG_${terraform.workspace}"
    Owner = "Denis Ananev"
  }
}

resource "aws_instance" "prod_1" {
  ami                    = data.aws_ami.latest_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id]
  user_data              = filebase64("user_data.sh")
  tags = {
    Name  = "server_${terraform.workspace}"
    Owner = "Denis Ananev"
  }
}

#---------------------------------------

