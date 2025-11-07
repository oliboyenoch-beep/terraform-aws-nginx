/*
# EC2 instance - installs Nginx and deploys GitHub project automatically
resource "aws_instance" "web" {
  # ... your EC2 configuration ...
}

# (Optional) associate an Elastic IP so IP doesn't change on stop/start
resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name = "terraform-nginx-eip"
  }
}
*/