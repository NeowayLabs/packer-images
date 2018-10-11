#!/bin/bash

set -o errexit
set -o nounset

#Generate a temporary key
ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""

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
