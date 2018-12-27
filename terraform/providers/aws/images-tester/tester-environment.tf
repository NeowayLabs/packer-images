terraform {
  required_version = "0.11.11"
}

resource "random_id" "server" {
  byte_length = 8
}

provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["neoway-image-${var.travis_build_id}"]
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "ubuntu" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "t3.micro"
  key_name        = "${var.aws_ssh_keyname}"
  security_groups = ["allow_all"]

  tags = {
    Name = "tester-vm-${random_id.server.hex}"
  }
}
