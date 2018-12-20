#!/bin/bash

set -o errexit
set -o nounset

#Initialize packer environment
make terraform-init provider=azure env=images-builder
make terraform-apply provider=azure env=images-builder

make packer-build env=azure image=image-ubuntu

#Initialize tester environment
make terraform-init provider=azure env=images-tester
make terraform-apply provider=azure env=images-tester

#todo test goss

#Destroy tester environment
make terraform-destroy provider=azure env=images-tester
