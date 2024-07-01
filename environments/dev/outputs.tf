# outputs from the resources created in main.tf

output "server_public_dns" {
  value = aws_instance.server.public_dns
}

output "agent_public_dns" {
  value = aws_instance.agent.public_dns
}
