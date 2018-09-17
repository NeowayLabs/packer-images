# Packer images

Default image builder for Neoway environment.

This project was builded for grant a set of internal patterns of security and monitoring for all our machines. We use [Terraform](https://www.terraform.io) to provide the structure, [Packer](https://www.packer.io) to build the default image, [Ansible](https://www.ansible.com) to execute and install all what we want, and [Docker](https://www.docker.com) to put all this tools together and don't blow your localhost.

## Prerequisites

* [Docker](https://docs.docker.com/engine/installation/)

## Getting started

## Select your cloud provider

At moment, this project supports:
- Azure
- Digital Ocean

Feel free to add more builders. The list of available builders are [here](https://www.packer.io/docs/builders/index.html).

### Export your credentials as environment variables

### Azure
[Create Azure Service Principal](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html) then export the credentials.

```bash
$ export AZURE_CLIENT_ID=YOUR_AZURE_CLIENT_ID
$ export AZURE_CLIENT_SECRET=YOUR_AZURE_CLIENT_SECRET
$ export AZURE_SERVICE_PRINCIPAL=YOUR_AZURE_SERVICE_PRINCIPAL
$ export AZURE_SUBSCRIPTION_ID=YOUR_AZURE_SUBSCRIPTION_ID
$ export AZURE_TENANT_ID=YOUR_AZURE_TENANT_ID
```

### Digital Ocean
[Create a Digital Ocean API KEY](https://www.digitalocean.com/docs/api/create-personal-access-token/) then export the credentials.

```bash
$ export DO_API_KEY=YOUR_DO_API_KEY
```

### Setup

Setup the docker image with [Terraform](https://www.terraform.io/) and [Packer](https://packer.io) to get things done.

```bash
$ make setup
```

## Create the infrastructure

NOTE: If you are using Digital Ocean as your cloud provider, you can jump this step to [packer](#initialize-packer)


In this README file we use `azure` as `provider` argument value, and `images-builder` as `env` argument value. The following `provider` and `env` are also available:

provider
 - azure
 - digital-ocean

env
 - images-builder
 - images-tester


### Initialize the packer environment

```bash
$ make terraform-init provider=azure env=images-builder
```

### Create the packer environment

```bash
$ make terraform-apply env=images-builder
```

### Initialize packer

In this README file we use `azure` as `env` argument value, and `image-ubuntu` as `image` argument value. The following `env` and `images` are also available:

env
 - azure
 - digital-ocean

images
 - image-ubuntu

```bash
$ make packer-build env=azure image=image-ubuntu
```

### Destroy the packer environment

TIP: Just use this if you want destroy everything what you build (include the packer image).

```bash
$ make terraform-destroy env=images-builder
```
