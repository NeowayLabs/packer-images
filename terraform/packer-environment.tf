provider "azurerm" {
  version = "~> 1.1"
}

terraform {
  required_version = "0.11.7"
}

resource "azurerm_resource_group" "packer-rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags {
    environment = "packer-default"
  }
}
