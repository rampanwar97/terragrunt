locals {
  env = {
    defaults = {
      nsg_rules = [
        {
          name                   = "AllowSSH"
          priority               = 120
          destination_port_range = "22"
        },
        {
          name                   = "web-port-http"
          priority               = 140
          destination_port_range = "80" //temp port
        },
        {
          name                   = "web-port-https"
          priority               = 160
          destination_port_range = "443" //temp port
        }
      ]

    }
    tmdc = {
      name                       = "azure-linuxvm"
      resource_group_name        = "Engineering"
      linux_virtual_machine_size = "Standard_DS1_v2"
      location                   = "east us"
      ssh_user                   = "azureuser"
    }
    devops = {
      name                       = "azure-linuxvm"
      resource_group_name        = "DevOps"
      linux_virtual_machine_size = "Standard_DS1_v2"
      location                   = "east us"
      ssh_user                   = "azureuser"
    }
  }
  workspace = merge(local.env["defaults"], local.env[terraform.workspace])
}