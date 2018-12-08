### Azure

### Export your credentials as environment variables

[Create Azure Service Principal](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html) then export the credentials.

```bash
$ export AZURE_CLIENT_ID=YOUR_AZURE_CLIENT_ID
$ export AZURE_CLIENT_SECRET=YOUR_AZURE_CLIENT_SECRET
$ export AZURE_SERVICE_PRINCIPAL=YOUR_AZURE_SERVICE_PRINCIPAL
$ export AZURE_SUBSCRIPTION_ID=YOUR_AZURE_SUBSCRIPTION_ID
$ export AZURE_TENANT_ID=YOUR_AZURE_TENANT_ID
```

## Create the infrastructure

### Initialize the packer environment with terraform 

This step initialize with terraform an environment where the VHD created by packer will be stored.

```bash
$ make terraform-init provider=azure env=images-builder
```

### Create the packer environment with terraform

This step create with packer on cloud provider an environment where the VHD will be stored.

```bash
$ make terraform-apply provider=azure env=images-builder
```

### Initialize packer

```bash
$ make packer-build env=azure image=image-ubuntu
```

After this step, you will have a blob storage with your VHD builded.

### Destroy the packer environment

TIP: don't destroy the `env` where is the build image. You will use this for your VMs later.

```bash
$ make terraform-destroy provider=azure env=images-tester
```
