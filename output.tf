output "loabbalancerdns" {
  value = aws_lb.myalb.dns_name
}

output "webserver1_PUBLIC_IP" {
  value = aws_instance.webserver1.public_ip
}

output "webserver2_PUBLIC_IP" {
  value = aws_instance.webserver2.public_ip
}