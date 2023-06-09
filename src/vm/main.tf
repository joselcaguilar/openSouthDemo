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

provider "azurerm" {
  subscription_id = "4572a41c-c128-4e47-bbbc-19d1a188492d"
  tenant_id       = "16b3c013-d300-468d-ac64-7eda0820b6d3"
  features {}
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
  virtual_network_name = azurerm_virtual_network.vnethub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nicvm" {
  name                = "nic1"
  location            = azurerm_resource_group.hugrg.location
  resource_group_name = azurerm_resource_group.hugrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snetvm.id
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
    azurerm_network_interface.nicvm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
