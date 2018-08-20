# Global Variables

variable "location" {
  description = "The location where resources are created"
  default     = "eastus2"
}

# Builder variables

variable "builder_resource_group_name" {
  description = "The name of the resouce groupe used by packer"
  default     = "packer-images"
}

variable "builder_image_name" {
  description = "Image name provisioned by packer"
  default = "default-image-azure"
}

# Tester variables

variable "tester_env" {
  description = "Default name for builder environment"
  default = "tester"
}

variable "tester_resource_group_name" {
  description = "The name of the resouce groupe used by tester"
  default     = "tester"
}

variable "tester_vnet" {
  description = "Address for tester vnet"
  default = "10.181.0.0/16"
}

variable "tester_subnet" {
  description = "Address for tester subnet"
  default = "10.181.1.0/24"
}

variable "tester_nic_name" {
  description = "Nic tester name"
  default = "tester-nic"
}

variable "tester_vm_name" {
  description = "tester vm name"
  default = "tester-vm"
}

variable "tester_user" {
  description = "user for tester vm"
  default = "packer"
}

variable "tester_vm_size" {
  description = "Azure vm size"
  default = "Standard_DS2_v2"
}

variable "TF_VAR_user" {
  default = ""
}
