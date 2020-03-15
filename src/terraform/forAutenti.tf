variable "default_name" {
  default = "forDevOps01"
}

variable "resources" {
  default = ["forDevOps01LoadBalancer", "forDevOps01Node1", "forDevOps01Node2"]
}

variable "software_tags" {
  type = map
  default = {
    "forDevOps01LoadBalancer" = "haproxy"
    "forDevOps01Node1" = "nginx_on_docker"
    "forDevOps01Node2" = "nginx_on_docker"
  }
}

provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name      = var.default_name
  location  = "West Europe"
}

resource "azurerm_public_ip" "publicip" {
  count = length(var.resources)
  name = var.resources[count.index]
  location  = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

output "public_ips" {
  value = zipmap(var.resources[*] , azurerm_public_ip.publicip[*].ip_address)
}

resource "azurerm_virtual_network" "vnet" {
  name = var.default_name
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name = var.default_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix = "10.0.1.0/24"
}

resource "azurerm_network_interface" "nic" {
  count = length(var.resources)
  name = var.resources[count.index]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = var.resources[count.index]
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
}

output "private_ips" {
  value = zipmap(var.resources[*] , azurerm_network_interface.nic[*].private_ip_address)
}

resource "azurerm_virtual_machine" "vm" {
  count = length(var.resources)
  name = var.resources[count.index]
  location            = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  vm_size               = "Standard_DS1_v2" # the cheapest available in hardware cluster and supports Premium storage

  storage_os_disk {
    name = var.resources[count.index]
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name = var.resources[count.index]
    admin_username = "vagrant"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/vagrant/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = {
    software = lookup(var.software_tags, var.resources[count.index], "default")
  }
}
