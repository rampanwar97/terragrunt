output "ssh_host_name" {
  value = azurerm_public_ip.linuxvm_public_ip.ip_address
}

output "ssh_port" {
  value = "22"
}

output "ssh_user_name" {
  value = local.workspace["ssh_user"]
}
