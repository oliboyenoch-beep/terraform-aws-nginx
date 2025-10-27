output "instance_id" {
  value = aws_instance.web.id
  description = "EC2 Instance ID"
}

output "public_ip" {
  value = coalesce(aws_eip.web_eip.public_ip, aws_instance.web.public_ip)
  description = "Public IP of the instance (Elastic IP if created)"
}

output "public_dns" {
  value = aws_instance.web.public_dns
  description = "Public DNS name of the instance"
}
