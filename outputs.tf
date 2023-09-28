output "server_ip" {
  value = aws_instance.prod_1.public_ip
}
