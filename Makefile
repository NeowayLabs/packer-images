include help.mk

.DEFAULT_GOAL := help

provider-dir = terraform/providers/azure/$(env)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	docker_ssh_opts =  -e SSH_AUTH_SOCK=$(SSH_AUTH_SOCK) \
	--volume $(SSH_AUTH_SOCK):$(SSH_AUTH_SOCK)
endif
ifeq ($(UNAME_S),Darwin)
	docker_ssh_opts = --volume $(HOME)/.ssh/id_rsa:/root/.ssh/id_rsa:ro
endif

# All the defaults configurations to use inside your container.

base-docker-run = docker run \
	--env ARM_CLIENT_ID=$(AZURE_CLIENT_ID) \
	--env ARM_CLIENT_SECRET=$(AZURE_CLIENT_SECRET) \
	--env ARM_SUBSCRIPTION_ID=$(AZURE_SUBSCRIPTION_ID) \
	--env ARM_TENANT_ID=$(AZURE_TENANT_ID) \
	--env AZURE_CLIENT_ID=$(AZURE_CLIENT_ID) \
	--env AZURE_CLIENT_SECRET=$(AZURE_CLIENT_SECRET) \
	--env AZURE_SECRET=$(AZURE_CLIENT_SECRET) \
	--env AZURE_SERVICE_PRINCIPAL=$(AZURE_SERVICE_PRINCIPAL) \
	--env AZURE_SUBSCRIPTION_ID=$(AZURE_SUBSCRIPTION_ID) \
	--env AZURE_TENANT=$(AZURE_TENANT_ID) \
	--env AZURE_TENANT_ID=$(AZURE_TENANT_ID) \
	--rm \
	--volume $(shell pwd):/packer-images \
	$(docker_ssh_opts) \

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi

terraform-docker-run = $(base-docker-run) \
	--interactive \
	--tty \
	--workdir /packer-images/$(provider-dir) \
	packer-images

packer-docker-run = $(base-docker-run) \
	--user packer \
	--workdir /packer-images/packer/builders/azure/image-ubuntu/ \
	packer-images

.PHONY: bash
bash:
	$(base-docker-run) \
	--interactive \
	--tty \
	packer-images /bin/bash

# Terraform commands

.PHONY: terraform-apply
terraform-apply: guard-env ##@terraform Build specified environment
	$(terraform-docker-run) \
	terraform apply \
	-auto-approve=false \
	-parallelism=100 \
	.

.PHONY: terraform-destroy
terraform-destroy: guard-env ##@terraform Destroy specified environment
	$(terraform-docker-run) \
	terraform destroy \
	-parallelism=100 \
	.

.PHONY: terraform-init
terraform-init: guard-env ##@terraform Initialize specified environment
	$(terraform-docker-run) \
	terraform init \
	.

.PHONY: terraform-fmt
terraform-fmt: ##@terraform Rewrite configuration files to a canonical format and style
	@$(base-docker-run) \
	--workdir /packer-images/terraform \
	packer-images \
	terraform fmt

.PHONY: terraform-validate
terraform-validate: guard-env ##@terraform Validate specified environment
	@$(terraform-docker-run) \
	terraform validate

# Packer commands

.PHONY: packer-build
packer-build: ##@packer Build artifacts
	$(packer-docker-run) \
	packer build -force provisioner.json

.PHONY: packer-debug
packer-debug: ##@packer Build artifacts in debug mode
	$(packer-docker-run) \
	packer build -force -debug provisioner.json

.PHONY: packer-fmt
packer-fmt: ##@packer Rewrite configuration files to a canonical format and style
	@$(base-docker-run) \
	--workdir /packer-images/hack \
	packer-images \
	bash packer-fmt.sh

.PHONY: packer-validate
packer-validate: ##@packer Validate artifacts
	@$(packer-docker-run) \
	packer validate provisioner.json

# Test commands
.PHONY: test
test: ##@test Run tests
	bash hack/test.sh

# Default setup

.PHONY: setup
setup: ##@setup Build and copy the tools needed to run this project
	@echo "Copying git hooks"
	cp -v githooks/pre-commit .git/hooks/pre-commit && \
	chmod +x .git/hooks/pre-commit
	@echo "Building docker image"
	docker build . -t packer-images
	@echo "Done!"
