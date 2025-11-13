#!/bin/bash
# Local deployment script for Linux/macOS

set -e

echo "🚀 Starting local Terraform deployment..."

# Generate SSH key pair
TIMESTAMP=$(date +%s)
KEY_NAME="local-key-${TIMESTAMP}"
PRIVATE_KEY="terraform_key"
PUBLIC_KEY="terraform_key.pub"

echo "🔑 Generating SSH key pair..."
ssh-keygen -t rsa -b 2048 -f $PRIVATE_KEY -N ""
chmod 600 $PRIVATE_KEY

PUBLIC_KEY_CONTENT=$(cat $PUBLIC_KEY)

echo "Key name: $KEY_NAME"
echo "Public key generated successfully"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Plan deployment
echo "📋 Planning deployment..."
terraform plan \
  -var="key_name=$KEY_NAME" \
  -var="public_key=$PUBLIC_KEY_CONTENT" \
  -out=tfplan

# Apply deployment
echo "🚀 Applying deployment..."
terraform apply -auto-approve tfplan

# Get instance details
INSTANCE_IP=$(terraform output -raw public_ip)
INSTANCE_ID=$(terraform output -raw instance_id)

echo "✅ Deployment successful!"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $INSTANCE_IP"

# Wait for instance to be ready
echo "⏳ Waiting for instance to be ready..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Wait for SSH
echo "🔌 Waiting for SSH to be available..."
for i in {1..20}; do
  if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
     -i $PRIVATE_KEY ec2-user@$INSTANCE_IP 'echo "Ready"' 2>/dev/null; then
    echo "SSH is ready!"
    break
  fi
  echo "Attempt $i/20: Waiting 10s..."
  sleep 10
done

# Install Nginx
echo "📦 Installing Nginx..."
scp -o StrictHostKeyChecking=no -i $PRIVATE_KEY \
  install-nginx.sh ec2-user@$INSTANCE_IP:/tmp/

ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY \
  ec2-user@$INSTANCE_IP 'chmod +x /tmp/install-nginx.sh && /tmp/install-nginx.sh'

echo "✅ Deployment completed successfully!"
echo "🌐 Access your server at: http://$INSTANCE_IP"

# Cleanup
echo "🧹 Cleaning up SSH keys..."
rm -f $PRIVATE_KEY $PUBLIC_KEY