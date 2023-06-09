terraform {
  required_version = ">=1.4.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.5.0"
    }
  }
  backend "azurerm" {
    storage_account_name = "tfstateoscodestg"
    container_name       = "tfstate"
    key                  = "hub.tfstate"
    resource_group_name  = "tf-dependencies"
  }
}

resource "azurerm_resource_group" "hugrg" {
  name     = "hub-opensouthcode"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnethub" {
  name                = "hub-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hugrg.location
  resource_group_name = azurerm_resource_group.hugrg.name
}

resource "azurerm_subnet" "snetvm" {
  name                 = "internalsnet"
  resource_group_name  = azurerm_resource_group.hugrg.name
  virtual_network_name = azurerm_virtual_network.hugrg.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nicvm" {
  name                = "nic1"
  location            = azurerm_resource_group.hugrg.location
  resource_group_name = azurerm_resource_group.hugrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hugrg.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "password" {
  length  = 8
  special = true
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "opensouthvm"
  resource_group_name             = azurerm_resource_group.hugrg.name
  location                        = azurerm_resource_group.hugrg.location
  size                            = "Standard_D2s_v5"
  disable_password_authentication = false
  admin_username                  = "adminuser"
  admin_password                  = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}

output "admin_password" {
  value = random_password.password.result
}
