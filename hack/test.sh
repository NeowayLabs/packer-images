#!/bin/bash

set -o errexit
set -o nounset

#Initialize packer environment
make terraform-init env=images-builder
make terraform-apply env=images-builder

make packer-build

#Initialize tester environment
make terraform-init env=images-tester
make terraform-apply env=images-tester

#todo test goss

#Destroy tester environment
make terraform-destroy env=images-tester
