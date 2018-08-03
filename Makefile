.DEFAULT_GOAL := setup

# All the defaults configurations to use inside your container.

base-docker-run = docker run \
	--rm \
	-e ARM_CLIENT_ID=$(AZURE_CLIENT_ID) \
	-e ARM_CLIENT_SECRET=$(AZURE_CLIENT_SECRET) \
	-e ARM_SUBSCRIPTION_ID=$(AZURE_SUBSCRIPTION_ID) \
	-e ARM_TENANT_ID=$(AZURE_TENANT_ID) \
	-e AZURE_CLIENT_ID=$(AZURE_CLIENT_ID) \
	-e AZURE_CLIENT_SECRET=$(AZURE_CLIENT_SECRET) \
	-e AZURE_SECRET=$(AZURE_CLIENT_SECRET) \
	-e AZURE_SERVICE_PRINCIPAL=$(AZURE_SERVICE_PRINCIPAL) \
	-e AZURE_SUBSCRIPTION_ID=$(AZURE_SUBSCRIPTION_ID) \
	-e AZURE_TENANT=$(AZURE_TENANT_ID) \
	-e AZURE_TENANT_ID=$(AZURE_TENANT_ID) \
	-v $(shell pwd):/packer-images

terraform-docker-run = $(base-docker-run) \
	-w  /packer-images/terraform \
	-it default-image-azure

packer-docker-run = $(base-docker-run) \
	-w  /packer-images/packer \
	-it default-image-azure

.PHONY: bash
bash:
	$(base-docker-run) -it packer-images /bin/bash

# Terraform commands

.PHONY: terraform-apply
terraform-apply:
	$(terraform-docker-run) \
	terraform apply \
	-auto-approve=false \
	-parallelism=100 \
	.

.PHONY: terraform-destroy
terraform-destroy:
	$(terraform-docker-run) \
	terraform destroy \
	-parallelism=100 \
	.

.PHONY: terraform-init
terraform-init:
	$(terraform-docker-run) \
	terraform init \
	.

.PHONY: terraform-plan
terraform-plan:
	$(terraform-docker-run) \
	terraform plan \
	-var-file=${var-file} \
	$(terraform-args) \
	.

# Packer commands

.PHONY: packer-build
packer-build:
	$(packer-docker-run) \
	packer build -force provisioner.json

	.PHONY: packer-debug
	packer-build:
		$(packer-docker-run) \
		packer build -force -debug provisioner.json

# Default setup

.PHONY: setup
setup:
	@echo "Updating submodules"
	git submodule update --init --recursive
	@echo "Building docker image"
	docker build . -t packer-images
	@echo "Done!"
