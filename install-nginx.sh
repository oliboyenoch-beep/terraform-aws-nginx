#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt-get update -y

echo "Installing Nginx..."
sudo apt-get install -y nginx

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Nginx installation completed successfully!"
sudo systemctl status nginx --no-pager