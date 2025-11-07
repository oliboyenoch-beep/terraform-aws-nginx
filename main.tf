# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Create Key Pair from your local public key
resource "aws_key_pair" "ec2_key" {
  key_name   = "john-ec2-key"
  public_key = file("C:/Users/Hewlett Packard/.ssh/id_rsa.pub")
}

# Security Group for SSH + HTTP
resource "aws_security_group" "web_sg" {
  name        = "nginx-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

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

# EC2 Instance
resource "aws_instance" "nginx_server" {
  ami           = "ami-0360c520857e3138f" # Ubuntu 22.04 us-east-1
  instance_type = "t3.micro"
  key_name      = "john-ec2-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "terraform-nginx-server"
  }
}

# Elastic IP
resource "aws_eip" "web_eip" {
  instance = aws_instance.nginx_server.id
  domain   = "vpc"

  tags = {
    Name = "nginx-eip"
  }
}
