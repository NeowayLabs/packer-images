#!/bin/bash

set -o errexit

declare _path_="$(pwd)"
declare status="0"
declare credentials_file="/tmp/.gcp/credentials.json"

echo ${_path_} | grep google-cloud > /dev/null 2>&1 || status="1"

if [[ ${status} = "0" ]]; then
    if [[ -z ${GCP_TOKEN} ]]; then
        echo "Error: You need declare and export GCP_TOKEN variable"
        exit 1
    fi
    # Running inside Travis CI or local
    if [[ -z ${TRAVIS_BUILD_ID} ]]; then
        mkdir -p /tmp/.gcp
        echo ${GCP_TOKEN} | jq . > ${credentials_file}
        export TRAVIS_BUILD_ID=${RANDOM}
        export TF_VAR_travis_build_id=${TRAVIS_BUILD_ID}
    else
        mkdir -p /tmp/.gcp
        echo ${GCP_TOKEN} | base64 -d > ${credentials_file}
    fi
fi

/bin/bash -c "${*}"
