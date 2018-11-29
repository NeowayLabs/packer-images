#!/bin/bash

set -o errexit

declare _path_="$(pwd)"
declare status="0"
declare credentials_file="/root/.gcp/credentials.json"

echo ${_path_} | grep google-cloud > /dev/null 2>&1 || status="1"

if [[ ${status} = "0" ]]; then
    if [[ -z ${gcp_token} ]]; then
        echo "Error: You need declare and export gcp_token variable"
        exit 1
    fi
    # Running inside Travis CI or local
    if [[ -z ${TRAVIS_BUILD_ID} ]]; then
        echo ${gcp_token} | base64 -d > ${credentials_file}
    else
        echo ${gcp_token} | jq . > ${credentials_file}
        export TRAVIS_BUILD_ID=${RANDOM}
        export TF_VAR_travis_build_id=${TRAVIS_BUILD_ID}
    fi
fi

/bin/bash -c "${*}"
