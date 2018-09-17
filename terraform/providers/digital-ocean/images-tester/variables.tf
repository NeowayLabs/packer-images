# Global variables

variable "location" {
  description = "The Digital Ocean region in which the resources should exist"
  default     = "nyc3"
}

variable "do_token" {
  description = "Digital Ocean API KEY"
  default = ""
}
