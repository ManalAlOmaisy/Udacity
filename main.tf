terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# packer image  

data "azurerm_image" "packerimage" {
  name                = "myPackerImage"
  resource_group_name = azurerm_resource_group.rgName.name
}

output "image_id" {
  value = data.azurerm_image.packerimage.id
}

# resource group
resource "azurerm_resource_group" "rgName" {
  name     = var.resource_group_name
  location = var.location
}

# create vnet

resource "azurerm_virtual_network" "udacity_vnet" {
  name                = "var.prefix-vn"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rgName.name
  location            = var.location
  tags = {
    tobedeleted = "yes"
  }

}

# create Subnet

resource "azurerm_subnet" "udacity_subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.rgName.name
  virtual_network_name = azurerm_virtual_network.udacity_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

# network security group

resource "azurerm_network_security_group" "udacity_nsg" {
  name                = "my-nsg"
  resource_group_name = azurerm_resource_group.rgName.name
  location            = var.location
  tags = {
    tobedeleted = "yes"
  }
}

resource "azurerm_network_security_rule" "deny_internet" {
  name                        = "internet-deny"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgName.name
  network_security_group_name = azurerm_network_security_group.udacity_nsg.name
}

resource "azurerm_network_security_rule" "allow_vnet_inbound" {
  name                        = "allow-vnet-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rgName.name
  network_security_group_name = azurerm_network_security_group.udacity_nsg.name
}

resource "azurerm_network_security_rule" "allow_vnet_outbound" {
  name                        = "allow-vnet-outbound"
  priority                    = 300
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rgName.name
  network_security_group_name = azurerm_network_security_group.udacity_nsg.name
}

resource "azurerm_network_security_rule" "allow_http_lb" {
  name                        = "allow-HTTP-from-LB"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "LoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgName.name
  network_security_group_name = azurerm_network_security_group.udacity_nsg.name
}


# network interface

resource "azurerm_network_interface" "udacity_nic" {
  count               = var.vm_count
  name                = "my-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgName.name
  tags = {
    tobedeleted = "yes"
  }

  ip_configuration {
    name                          = "my-nic-ipconfig"
    subnet_id                     = azurerm_subnet.udacity_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Public ip

resource "azurerm_public_ip" "udacity_public_ip" {
  name                = "my-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgName.name
  allocation_method   = "Dynamic"
  tags = {
    tobedeleted = "yes"
  }
}

# Load balancer

resource "azurerm_lb" "udacity_lb" {
  name                = "my-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgName.name

  frontend_ip_configuration {
    name                 = "lb-frontend"
    public_ip_address_id = azurerm_public_ip.udacity_public_ip.id
  }
  tags = {
    tobedeleted = "yes"
  }
}

# Backend pool 

resource "azurerm_lb_backend_address_pool" "udacity_backend_pool" {
  name            = "my-backend-pool"
  loadbalancer_id = azurerm_lb.udacity_lb.id
}

# virual machine availability set

resource "azurerm_availability_set" "udacity_availability_set" {
  name                = "my-availability-set"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgName.name
  tags = {
    tobedeleted = "yes"
  }
}

# create vm  
resource "azurerm_virtual_machine" "vm_udacity" {
  count                 = var.vm_count
  name                  = "VM-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rgName.name
  availability_set_id   = azurerm_availability_set.udacity_availability_set.id
  network_interface_ids = [azurerm_network_interface.udacity_nic[count.index].id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    id = data.azurerm_image.packerimage.id
  }

  storage_os_disk {
    name              = "VMOSDisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "VM-${count.index}"
    admin_username = "azureuser"
    admin_password = "UserUdacity123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    project_name = "Deploying a Web Server in Azure",
    tobedeleted  = "yes"
  }
}














