output "haproxy_address" {
  value = "ssh://${aws_instance.haproxy.0.public_dns}"
}

output "haproxy_stats" {
  value = "http://${aws_instance.haproxy.0.public_dns}/haproxy?stats"
}

output "haproxy_web_frontend" {
  value = "http://${aws_instance.haproxy.0.public_dns}"
}

output "haproxy_vault_frontend" {
  value = "http://${aws_instance.haproxy.0.public_dns}:8200/ui/"
}

output "haproxy_web_frontend_secrets" {
  value = "http://${aws_instance.haproxy.0.public_dns}/secret.html"
}
