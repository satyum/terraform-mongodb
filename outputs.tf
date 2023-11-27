output "primary_instance_ip" {
  value = aws_instance.primary[0].public_ip
}

output "secondary_instance_ips" {
  value = aws_instance.secondary[*].private_ip
}
