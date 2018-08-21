# Packer images

Default image builder for Neoway environment.

This project was builded for grant a set of internal patterns of security and monitoring for all our machines. We use [Terraform](https://www.terraform.io) to provide the structure, [Packer](https://www.packer.io) to build the default image, [Ansible](https://www.ansible.com) to execute and install all what we want, and [Docker](https://www.docker.com) to put all this tools together and don't blow your localhost.

## Prerequisites

* [Docker](https://docs.docker.com/engine/installation/)

## Getting started

### Export your credentials as environment variables

[Create Azure Service Principal](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html) then export the credentials.

```bash
$ export AZURE_CLIENT_ID=YOUR_AZURE_CLIENT_ID
$ export AZURE_CLIENT_SECRET=YOUR_AZURE_CLIENT_SECRET
$ export AZURE_SERVICE_PRINCIPAL=YOUR_AZURE_SERVICE_PRINCIPAL
$ export AZURE_SUBSCRIPTION_ID=YOUR_AZURE_SUBSCRIPTION_ID
$ export AZURE_TENANT_ID=YOUR_AZURE_TENANT_ID
```

### Setup

Setup the docker image with [Terraform](https://www.terraform.io/) and [Packer](https://packer.io) to get things done.

```bash
$ make setup
```

## Create the infrastructure

In this README file we use `images-builder` as `env` argument value. The following `env` are also available:
 - images-builder
 - images-tester

### Initialize the packer environment

```bash
$ make terraform-init env=images-builder
```

### Create the packer environment

```bash
$ make terraform-apply env=images-builder
```

### Initialize packer

```bash
$ make packer-build
```

### Destroy the packer environment

TIP: Just use this if you want destroy everything what you build (include the packer image).

```bash
$ make terraform-destroy env=images-builder
```
