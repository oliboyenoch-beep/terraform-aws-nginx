output "instance_id" {
  value = aws_instance.nginx_server.id
}

output "public_ip" {
  value = coalesce(aws_eip.web_eip.public_ip, aws_instance.nginx_server.public_ip)
}

output "public_dns" {
  value = aws_instance.nginx_server.public_dns
}
