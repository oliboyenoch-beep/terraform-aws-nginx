terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"

  # Save Terraform state file locally instead of S3 or DynamoDB
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Create Key Pair using the public key passed from GitHub or local variable
resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_pair_name
  public_key = var.public_key_content
}

# Security Group for SSH + HTTP
resource "aws_security_group" "web_sg" {
  name        = "nginx-sg"
  description = "Allow SSH and HTTP"
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

  tags = {
    Name = "nginx-sg"
  }
}

# EC2 Instance - Ubuntu + Nginx
resource "aws_instance" "nginx_server" {
  ami                    = "ami-0360c520857e3138f" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "terraform-nginx-server"
  }
}

# Elastic IP for stable public IP
resource "aws_eip" "web_eip" {
  instance = aws_instance.nginx_server.id
  domain   = "vpc"

  tags = {
    Name = "nginx-eip"
  }
}

