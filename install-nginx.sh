#!/bin/bash
set -e

echo "Updating system packages..."
sudo yum update -y

echo "Installing Nginx..."
sudo amazon-linux-extras install nginx1 -y

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Creating a simple index page..."
sudo bash -c 'cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Nginx!</title>
</head>
<body>
    <h1>Nginx is running on AWS EC2!</h1>
    <p>Deployed automatically with Terraform and GitHub Actions</p>
    <p>Server: $(hostname)</p>
    <p>Date: $(date)</p>
</body>
</html>
EOF'

echo "Nginx installation completed successfully!"
sudo systemctl status nginx --no-pager