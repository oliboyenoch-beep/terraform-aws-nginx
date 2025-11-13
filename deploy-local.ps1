# Local deployment script for Windows PowerShell
Write-Host "Starting local Terraform deployment..." -ForegroundColor Green

# Generate SSH key pair
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$keyName = "local-key-$timestamp"
$privateKeyPath = "terraform_key"
$publicKeyPath = "terraform_key.pub"

Write-Host "Generating SSH key pair..." -ForegroundColor Yellow
ssh-keygen -t rsa -b 2048 -f $privateKeyPath -N '""'

if (-not (Test-Path $publicKeyPath)) {
    Write-Host "Failed to generate SSH key pair" -ForegroundColor Red
    exit 1
}

# Read public key content
$publicKey = Get-Content $publicKeyPath -Raw
$publicKey = $publicKey.Trim()

Write-Host "Key name: $keyName" -ForegroundColor Cyan
Write-Host "Public key generated successfully" -ForegroundColor Cyan

# Initialize Terraform
Write-Host "Initializing Terraform..." -ForegroundColor Yellow
terraform init

# Plan deployment
Write-Host "Planning deployment..." -ForegroundColor Yellow
terraform plan -var="key_name=$keyName" -var="public_key=$publicKey" -out=tfplan

# Apply deployment
Write-Host "Applying deployment..." -ForegroundColor Yellow
terraform apply -auto-approve tfplan

if ($LASTEXITCODE -eq 0) {
    # Get instance details
    $instanceIP = terraform output -raw public_ip
    $instanceID = terraform output -raw instance_id
    
    Write-Host "Deployment successful!" -ForegroundColor Green
    Write-Host "Instance ID: $instanceID" -ForegroundColor Cyan
    Write-Host "Public IP: $instanceIP" -ForegroundColor Cyan
    
    # Wait for instance to be ready
    Write-Host "Waiting for instance to be ready..." -ForegroundColor Yellow
    aws ec2 wait instance-running --instance-ids $instanceID
    
    # Wait for SSH
    Write-Host "Waiting for SSH to be available..." -ForegroundColor Yellow
    for ($i = 1; $i -le 20; $i++) {
        $sshTest = ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i $privateKeyPath ec2-user@$instanceIP 'echo "Ready"' 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SSH is ready!" -ForegroundColor Green
            break
        }
        Write-Host "Attempt $i/20: Waiting 10s..." -ForegroundColor Yellow
        Start-Sleep 10
    }
    
    # Install Nginx
    Write-Host "Installing Nginx..." -ForegroundColor Yellow
    scp -o StrictHostKeyChecking=no -i $privateKeyPath install-nginx.sh ec2-user@${instanceIP}:/tmp/
    ssh -o StrictHostKeyChecking=no -i $privateKeyPath ec2-user@$instanceIP 'chmod +x /tmp/install-nginx.sh && /tmp/install-nginx.sh'
    
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    Write-Host "🌐 Access your server at: http://$instanceIP" -ForegroundColor Green
    
} else {
    Write-Host "Deployment failed!" -ForegroundColor Red
}

# Cleanup
Write-Host "Cleaning up SSH keys..." -ForegroundColor Yellow
Remove-Item $privateKeyPath -ErrorAction SilentlyContinue
Remove-Item $publicKeyPath -ErrorAction SilentlyContinue