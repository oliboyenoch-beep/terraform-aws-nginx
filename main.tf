# =======================
# Provider
# =======================
provider "aws" {
  region = var.aws_region
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
  
  # If you have a fixed VPC, keep this.
  # If not, remove this line and let AWS choose default VPC.
  vpc_id = "vpc-06e02341c19b1b9dc"

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
  ami           = "ami-0360c520857e3138f"   # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t3.micro"                # Your preferred type
  key_name      = aws_key_pair.dynamic_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "terraform-ec2-web"
  }
}

