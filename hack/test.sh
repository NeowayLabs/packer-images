#!/bin/bash

set -o errexit
set -o nounset

status="0"
output=""

# Terraform tests
providers_azure="images-builder images-tester"

echo "Validate the syntax of the terraform files"
echo ""

for provider in ${providers_azure} ; do
    echo "Running in the ${provider} environment"
    output=$(make terraform-validate env=${provider}) || status=1
    if [ "${status}" != "0" ]; then
        echo "Error: ${output}"
        exit 1
    fi
done

echo "Done."
echo ""

# Packer tests

echo "Validate the syntax and configuration of the packer templates"
echo ""

output=$(make packer-validate) || status=1
if [ "${status}" != "0" ]; then
    echo "Error: ${output}"
fi

echo "Done."
echo ""
