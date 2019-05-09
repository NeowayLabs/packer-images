#!/bin/bash

set -o errexit
set -o nounset

### Google Tests ###

#Execute packer

make packer-build env=google-cloud image=image-ubuntu-18-04
make packer-build-latest env=google-cloud image=image-ubuntu-18-04

#Initialize tester environment
make terraform-init provider=google-cloud env=images-tester
make terraform-apply provider=google-cloud env=images-tester

#todo test goss

#Destroy tester environment
make terraform-destroy provider=google-cloud env=images-tester


### Azure Tests ###

#Initialize packer environment
#make terraform-init provider=azure env=images-builder
#make terraform-apply provider=azure env=images-builder

#make packer-build env=azure image=image-ubuntu

#Initialize tester environment
#make terraform-init provider=azure env=images-tester
#make terraform-apply provider=azure env=images-tester

#todo test goss

#Destroy tester environment
#make terraform-destroy provider=azure env=images-tester
