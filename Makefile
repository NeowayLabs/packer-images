include help.mk

.DEFAULT_GOAL := help

provider-dir-terraform = terraform/providers/$(provider)/$(env)
provider-dir-packer = packer/builders/$(env)/$(image)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	docker_ssh_opts =  -e SSH_AUTH_SOCK=$(SSH_AUTH_SOCK) \
	--volume $(SSH_AUTH_SOCK):$(SSH_AUTH_SOCK)
endif
ifeq ($(UNAME_S),Darwin)
	docker_ssh_opts = --volume $(HOME)/.ssh/:/home/packer/.ssh/:ro
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
	--env DO_API_KEY \
	--env GCP_TOKEN \
	--env TF_VAR_travis_build_id=$(TRAVIS_BUILD_ID) \
	--env TRAVIS_BUILD_ID \
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
	--workdir /packer-images/$(provider-dir-terraform) \
	neowaylabs/packer-images

packer-docker-run = $(base-docker-run) \
	--user packer \
	--workdir /packer-images/$(provider-dir-packer) \
	neowaylabs/packer-images

.PHONY: bash
bash:
	@$(base-docker-run) -it neowaylabs/packer-images /bin/bash


# Terraform commands

.PHONY: terraform-apply
terraform-apply: guard-provider guard-env ##@terraform Build specified environment
	@echo "Building terrform environment..."
	@$(terraform-docker-run) \
	terraform apply \
	-auto-approve=true \
	.

.PHONY: terraform-destroy
terraform-destroy: guard-provider guard-env ##@terraform Destroy specified environment
	@echo "Destroying terrform environment..."
	@$(terraform-docker-run) \
	terraform destroy \
	-auto-approve=true \
	-parallelism=100 \
	.

.PHONY: terraform-init
terraform-init: guard-provider guard-env ##@terraform Initialize specified environment
	@echo "Starting terrform environment..."
	@$(terraform-docker-run) \
	terraform init \
	.

.PHONY: terraform-fmt
terraform-fmt: ##@terraform Rewrite configuration files to a canonical format and style
	@$(base-docker-run) \
	--workdir /packer-images/terraform \
	packer-images \
	terraform fmt

# Packer commands

.PHONY: packer-build
packer-build: guard-env guard-image ##@packer Build artifacts
	@echo "Starting packer build..."
	@$(packer-docker-run) \
	packer build -force provisioner.json

.PHONY: packer-build-latest
packer-build-latest: guard-env guard-image ##@packer Build artifacts
	@echo "Starting packer build..."
	@$(packer-docker-run) \
	packer build -force provisioner-latest.json

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

.PHONY: test
test: ##@test Run CI tests on travis to all build steps
	@echo "Starting CI build..."
	bash hack/build.sh

# Default setup

.PHONY: setup
setup: ##@setup Build and copy the tools needed to run this project
	@echo "Copying git hooks"
	cp -v githooks/pre-commit .git/hooks/pre-commit && \
	chmod +x .git/hooks/pre-commit
	@echo "Building docker image"
	docker build . -t packer-images
	@echo "Done!"

.PHONY: pull
pull: ##@pull the latest docker version from dockerhub
	@echo "Downloading docker image"
	docker pull neowaylabs/packer-images
	@echo "Done!"
