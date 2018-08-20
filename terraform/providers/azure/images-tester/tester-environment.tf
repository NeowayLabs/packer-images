
# Set provider and terraform version
provider "azurerm" {
  version = "~> 1.1"
}

terraform {
  required_version = "0.11.7"
}

# Create resource group
resource "azurerm_resource_group" "builder_rg" {
  name     = "${var.builder_resource_group_name}"
  location = "${var.location}"
}

# Create Vnet
resource "azurerm_virtual_network" "builder_vnet" {
    name                 = "${var.builder_resource_group_name}-vnet"
    address_space        = "${var.builder_vnet}"
    location             = "${var.location}"
    resource_group_name  = "${var.builder_resource_group_name}"
}

# Create Subnet
resource "azurerm_subnet" "builder_subnet" {
    name                 = "${var.builder_env}-subnet"
    resource_group_name  = "${var.builder_resource_group_name}"
    virtual_network_name = "${azurerm_virtual_network.builder_vnet.name}"
    address_prefix       = "${var.builder_subnet}"
}

# Provisioning public IP
resource "azurerm_public_ip" "builder_public_ip" {
    name                         = "${var.builder_env}-public-ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.builder_resource_group_name}"
    public_ip_address_allocation = "dynamic"
}

# # Provisioning eth (w/ public IP)
resource "azurerm_network_interface" "builder_nic" {
    name                      = "${var.builder_nic_name}"
    location                  = "${var.location}"
    resource_group_name       = "${var.builder_resource_group_name}"
    network_security_group_id = "${azurerm_network_security_group.builder_nsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.builder_subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.builder_public_ip.id}"
    }

}

# Create Network Security Group and rule for SSH access
resource "azurerm_network_security_group" "builder_nsg" {
    name                = "${var.builder_env}-nsg"
    location            = "${var.location}"
    resource_group_name = "${var.builder_resource_group_name}"

    security_rule {
        name                       = "Allow ssh"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# # Image from packer reference to build a new VM
# data "azurerm_image" "builder_image" {
#   name                = "${var.packer_image_name}"
#   resource_group_name = "${var.packer_resource_group_name}"
# }


resource "azurerm_image" "builder_image" {
  name     = "${var.packer_image_name}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.builder_rg.name}"
  os_disk {
     os_type ="linux"
     os_state = "Generalized"
     caching = "ReadWrite"
  }
}




# Create virtual machine
resource "azurerm_virtual_machine_scale_set" "builder-vm" {
  name                = "${var.builder_vm_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.builder_rg.name}"

  delete_os_disk_on_termination    = "true"
  network_interface_ids            = ["${azurerm_network_interface.builder_nic.id}"]
  vm_size                          = "${var.builder_vm_size}"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id="${azurerm_image.builder_image.id}"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    admin_username = "${var.builder_user}"
    admin_password = ""
    computer_name  = "${var.builder_vm_name}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "${var.builder_user}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }
}
