# =======================
# Provider
# =======================
provider "aws" {
  region = var.aws_region
}

# =======================
# Data Sources
# =======================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ec2_instance_types" "free_tier" {
  filter {
    name   = "free-tier-eligible"
    values = ["true"]
  }
  
  filter {
    name   = "processor-info.supported-architecture"
    values = ["x86_64"]
  }
}

# =======================
# Key Pair (Dynamic from CI/CD)
# =======================
resource "aws_key_pair" "dynamic_key" {
  key_name   = var.key_name
  public_key = var.public_key_content
}

# =======================
# Security Group
# =======================
resource "aws_security_group" "web_sg" {
  name        = var.sg_name
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# =======================
# EC2 Instance
# =======================
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.dynamic_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  
  associate_public_ip_address = true

  tags = {
    Name = "terraform-ec2-web"
  }
  
  # Trigger deployment
}

