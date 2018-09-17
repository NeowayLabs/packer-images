# Set provider and terraform version

provider "digitalocean" {
  token = "${var.do_token}"
}

terraform {
  required_version = "0.11.7"
}

# Select snapshot to build

    data "digitalocean_image" "snapshot" {
      name = "ubuntu-neoway-image"
    }

# Create Droplet from packer snapshot

resource "digitalocean_droplet" "droplet" {
  image  = "${data.digitalocean_image.snapshot.image}"
  name   = "tester-droplet"
  region = "${var.location}"
  size   = "512mb"


  connection {
      user = "packer"
      type = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"
      timeout = "2m"
  }
}
