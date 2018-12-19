# Global variables

variable "gcp_token" {
  default = ""
}

variable "travis_build_id" {
  default = ""
}

variable "location" {
  description = "The Google cloud region in which the resources should exist"
  default     = "us-east4-a"
}

variable "project" {
  description = "The project where you will deploy your VM"
  default     = "blackops-qa"
}
