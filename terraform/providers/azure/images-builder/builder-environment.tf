provider "azurerm" {
  version = "~> 1.1"
}

terraform {
  required_version = "0.11.7"
}

resource "azurerm_resource_group" "packer_rg" {
  name     = "${var.builder_resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_storage_account" "packer_sa" {
  name                     = "${var.builder_storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.packer_rg.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "packer_sc" {
  name                  = "${var.builder_storage_container_name}"
  resource_group_name   = "${azurerm_resource_group.packer_rg.name}"
  storage_account_name  = "${azurerm_storage_account.packer_sa.name}"
  container_access_type = "private"
}
