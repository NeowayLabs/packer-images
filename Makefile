.DEFAULT_GOAL := setup

provider-dir = terraform/providers/azure/$(env)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	docker_ssh_opts =  -e SSH_AUTH_SOCK=$(SSH_AUTH_SOCK) \
	-v $(SSH_AUTH_SOCK):$(SSH_AUTH_SOCK)
endif
ifeq ($(UNAME_S),Darwin)
	docker_ssh_opts = -v $(HOME)/.ssh:/home/packer/.ssh:ro
endif

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
	-v $(shell pwd):/packer-images \
	$(docker_ssh_opts) \

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi

terraform-docker-run = $(base-docker-run) \
	-w  /packer-images/$(provider-dir) \
	-it packer-images

terraform-docker-run = $(base-docker-run) \
	-w  /packer-images/$(provider-dir) \
	-it packer-images

packer-docker-run = $(base-docker-run) \
	-w  /packer-images/packer/providers/azure/image-ubuntu/ \
	-it packer-images

.PHONY: bash
bash:
	$(base-docker-run) -it packer-images /bin/bash

# Terraform commands

.PHONY: terraform-apply
terraform-apply: guard-env
	$(terraform-docker-run) \
	terraform apply \
	-auto-approve=false \
	-parallelism=100 \
	.

.PHONY: terraform-destroy
terraform-destroy: guard-env
	$(terraform-docker-run) \
	terraform destroy \
	-parallelism=100 \
	.

.PHONY: terraform-init
terraform-init: guard-env
	$(terraform-docker-run) \
	terraform init \
	.

# Packer commands

.PHONY: packer-build
packer-build:
	$(packer-docker-run) \
	packer build -force provisioner.json

.PHONY: packer-debug
packer-debug:
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
