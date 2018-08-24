#!/bin/bash

set -o errexit
set -o nounset

status="0"
output=""

for file in $(find /packer-images/packer -type f -name "*.json"); do
    if [ "z${file}" != "z" ]; then
        output=$(cat ${file} | jq . 2>&1) || status=1
        if [ "${status}" != "0" ]; then
            echo "${file} [${output}]"
        else
            echo ${output} | jq . > ${file}
        fi
    fi
done

git diff --name-only | grep "^packer.*.json" || status=1
