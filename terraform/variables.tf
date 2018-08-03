variable "location" {
  description = "The location where resources are created"
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources are created"
  default     = "rg-packer-images"
}
