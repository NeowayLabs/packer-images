# Create resource group
resource "azurerm_resource_group" "tester_rg" {
  name     = "${var.tester_resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_image" "tester_image" {
  name = "${var.builder_image_name}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.builder_rg.name}"
  os_disk {
     os_type ="linux"
     os_state = "Generalized"
     caching = "ReadWrite"
  }
}

# Create Vnet
resource "azurerm_virtual_network" "tester_vnet" {
    name                 = "${var.tester_resource_group_name}-vnet"
    address_space        = ["${var.tester_vnet}"]
    location             = "${var.location}"
    resource_group_name  = "${var.tester_resource_group_name}"
}

# Create Subnet
resource "azurerm_subnet" "tester_subnet" {
    name                 = "${var.tester_env}-subnet"
    resource_group_name  = "${var.tester_resource_group_name}"
    virtual_network_name = "${azurerm_virtual_network.tester_vnet.name}"
    address_prefix       = "${var.tester_subnet}"
}



resource "azurerm_virtual_machine_scale_set" "tester_vm" {
  name                = "${var.tester_vm_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.tester_rg.name}"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
   id = "${azurerm_image.builder_image.id}"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # storage_profile_data_disk {
  #   lun          = 0
  #   caching        = "ReadWrite"
  #   create_option  = "Empty"
  #   disk_size_gb   = 10
  # }

  os_profile {
    computer_name_prefix = "${var.tester_vm_name}"
    admin_username       = "${var.tester_user}"
    admin_password       = ""
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "${var.builder_user}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
    name    = "networkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = "${azurerm_subnet.tester_subnet.id}"

      public_ip_address_configuration {
        name = ""
        idle_timeout = "4"
        domain_name_label = "Internet"
      }

    }

  }
}
