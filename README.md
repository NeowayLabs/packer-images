# Packer images

[![Build Status](https://travis-ci.org/NeowayLabs/packer-images.svg?branch=add-ci-azure-build)](https://travis-ci.org/NeowayLabs/packer-images)

Default image builder for Neoway environment.

This project was builded for grant a set of internal patterns of security and monitoring for all our machines. We use [Terraform](https://www.terraform.io) to provide the structure, [Packer](https://www.packer.io) to build the default image, [Ansible](https://www.ansible.com) to execute and install all what we want, and [Docker](https://www.docker.com) to put all this tools together and don't blow your localhost.

## Prerequisites

* [Docker](https://docs.docker.com/engine/installation/)

## Getting started

### Setup

Setup the docker image with [Terraform](https://www.terraform.io/) and [Packer](https://packer.io) to get things done.

```bash
$ make setup
```

## Select your cloud provider

At moment, this project supports:
- [Azure](docs/azure.md)
- [Google Cloud](docs/gcp.md)
- [Digital Ocean](docs/do.md)
- [Amazon Web Services](docs/aws.md)

Feel free to add more builders. The list of available builders are [here](https://www.packer.io/docs/builders/index.html).


## Arguments

On this project we separate the multi cloud schema and tools using arguments when executing make. The valid arguments are:

- `provider`

Used to set the cloud provider to build and manage your image. The valid providers at this time are:`azure`,`google-cloud`, `digital-ocean` and `aws`.

- `env`

Set the terraform environment to build your structure to build, deploy or test your image. The valid envs at this time are:`images-builder`,`images-tester` and `images-publisher`.

- `image`

Choose the OS type what you want to build. The valid images at this time are: `image-ubuntu`

Inside each cloud provider documentation, has a example with this arguments.

## Project particularities

- Travis CI:
- Debug:
