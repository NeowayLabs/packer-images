
# Set provider and terraform version

provider "azurerm" {
  version = "~> 1.1"
}

terraform {
  required_version = "0.11.7"
}

#Create resource group

resource "azurerm_resource_group" "tester_rg" {
  name     = "${var.tester_resource_group_name}"
  location = "${var.location}"
}

# Create Vnet

resource "azurerm_virtual_network" "tester_vnet" {
    name                 = "${var.prefix}-vnet"
    address_space        = ["${var.tester_vnet}"]
    location             = "${var.location}"
    resource_group_name  = "${var.tester_resource_group_name}"
}

# Create Subnet

resource "azurerm_subnet" "tester_subnet" {
    name                 = "${var.prefix}-subnet"
    resource_group_name  = "${var.tester_resource_group_name}"
    virtual_network_name = "${azurerm_virtual_network.tester_vnet.name}"
    address_prefix       = "${var.tester_subnet}"
}

# Provisioning public IP

resource "azurerm_public_ip" "tester_public_ip" {
    name                         = "${var.prefix}-public-ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.tester_resource_group_name}"
    public_ip_address_allocation = "dynamic"
}

# Provisioning eth (w/ public IP)

resource "azurerm_network_interface" "tester_nic" {
    name                      = "${var.tester_nic_name}"
    location                  = "${var.location}"
    resource_group_name       = "${var.tester_resource_group_name}"

    ip_configuration {
        name                          = "nic-config"
        subnet_id                     = "${azurerm_subnet.tester_subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.tester_public_ip.id}"
    }

}

# Set image to terraform use on VM
# This Custom Image already builded by packer

data "azurerm_image" "tester_image" {
  name                = "${var.builder_image_name}"
  resource_group_name = "${var.builder_resource_group_name}"
}

# Create virutal machine

resource "azurerm_virtual_machine" "tester_vm" {
  name                  = "${var.prefix}-vm"
  location              = "${var.location}"
  resource_group_name   = "${var.tester_resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.tester_nic.id}"]
  vm_size               = "${var.tester_vm_size}"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This is used here only for a tester environment

  delete_os_disk_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.tester_image.id}"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    admin_username = "${var.tester_user}"
    admin_password = ""
    computer_name  = "${var.tester_vm_name}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.tester_user}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }
}
