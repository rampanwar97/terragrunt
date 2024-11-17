resource "azurerm_virtual_network" "linuxvm_vnet" {
  name                = local.workspace["name"]
  location            = local.workspace["location"]
  resource_group_name = local.workspace["resource_group_name"]
  address_space       = ["10.0.0.0/16"]

  tags = {
    Name = "${local.workspace["name"]}"
  }
}

resource "azurerm_subnet" "linuxvm_subnet" {
  name                 = local.workspace["name"]
  resource_group_name  = local.workspace["resource_group_name"]
  virtual_network_name = azurerm_virtual_network.linuxvm_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [
    azurerm_virtual_network.linuxvm_vnet
  ]
}

resource "azurerm_public_ip" "linuxvm_public_ip" {
  name                = local.workspace["name"]
  resource_group_name = local.workspace["resource_group_name"]
  location            = local.workspace["location"]
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "linuxvm_nic" {
  name                = local.workspace["name"]
  location            = local.workspace["location"]
  resource_group_name = local.workspace["resource_group_name"]

  ip_configuration {
    name                          = "${local.workspace["name"]}-network-config"
    subnet_id                     = azurerm_subnet.linuxvm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linuxvm_public_ip.id
  }

  depends_on = [
    azurerm_subnet.linuxvm_subnet,
    azurerm_public_ip.linuxvm_public_ip
  ]
}

resource "azurerm_network_security_group" "linuxvm_nsg" {
  name                = local.workspace["name"]
  location            = local.workspace["location"]
  resource_group_name = local.workspace["resource_group_name"]

  dynamic "security_rule" {
    for_each = local.workspace["nsg_rules"]
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.linuxvm_nic.id
  network_security_group_id = azurerm_network_security_group.linuxvm_nsg.id

  depends_on = [
    azurerm_network_interface.linuxvm_nic,
    azurerm_network_security_group.linuxvm_nsg
  ]
}

data "azurerm_platform_image" "ubuntu" {
  location  = local.workspace["location"]
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = local.workspace["name"]
  location              = local.workspace["location"]
  resource_group_name   = local.workspace["resource_group_name"]
  network_interface_ids = [azurerm_network_interface.linuxvm_nic.id]
  size                  = local.workspace["linux_virtual_machine_size"]

  computer_name                   = "linuxvm"
  admin_username                  = local.workspace["ssh_user"]
  disable_password_authentication = true

  custom_data = filebase64("./docker.tpl")

  connection {
    host        = self.public_ip_address
    user        = local.workspace["ssh_user"]
    type        = "ssh"
    private_key = file("~/Rubik/cred/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sleep 60",
      "sudo chmod +x /usr/local/bin/docker-compose",
    ]
  }

  os_disk {
    name                 = "${local.workspace["name"]}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.ubuntu.publisher
    offer     = data.azurerm_platform_image.ubuntu.offer
    sku       = data.azurerm_platform_image.ubuntu.sku
    version   = data.azurerm_platform_image.ubuntu.version
  }

  admin_ssh_key {
    username   = local.workspace["ssh_user"]
    public_key = file("~/Rubik/cred/id_rsa.pub")
  }

  depends_on = [
    azurerm_network_interface.linuxvm_nic,
    data.azurerm_platform_image.ubuntu
  ]
}