# Use a static Ubuntu 22.04 LTS AMI for us-east-1 region
variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS in us-east-1"
  type        = string
  default     = "ami-0360c520857e3138f"
}

# Create an AWS key pair from your local public key file
resource "aws_key_pair" "deployer" {
  key_name   = var.key_pair_name

  # prefer public_key_content (from CI secrets); if empty you can still use local file by setting the var when running locally.
  public_key = var.public_key_content
}


# Security group allowing SSH and HTTP
resource "aws_security_group" "ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH (22) and HTTP (80) inbound"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

# EC2 instance - installs Nginx and deploys GitHub project automatically

resource "aws_instance" "web" {
ami                    = var.ami_id
instance_type          = var.instance_type
key_name               = "john-ec2-key"  # <- static key name
vpc_security_group_ids = [aws_security_group.ssh_http.id]

# user_data script installs nginx + deploys website from GitHub

user_data = <<-EOF
#!/bin/bash
set -e

```
# Update and install dependencies
apt-get update -y
apt-get install -y nginx git

# Remove default Nginx files
rm -rf /var/www/html/*

# Clone your GitHub repository (change URL if needed)
git clone https://github.com/Adetola-Adedoyin/EduCloud-frontend-app.git /var/www/html/

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Enable and restart Nginx
systemctl enable nginx
systemctl restart nginx
```

EOF

tags = {
Name = "terraform-nginx"
}
}

# (Optional) associate an Elastic IP so IP doesn't change on stop/start
resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name = "terraform-nginx-eip"
  }
}
