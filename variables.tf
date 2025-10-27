variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name to give the AWS key pair"
  type        = string
  default     = "john-ec2-key"
}

variable "public_key_path" {
  description = "Path to your public SSH key on local machine (e.g. ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "C:/Users/Hewlett Packard/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH (default = your IP open to all: 0.0.0.0/0). For security, set to your IP like 203.0.113.5/32"
  type        = string
  default     = "102.89.76.167/32"
}
