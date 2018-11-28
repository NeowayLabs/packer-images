#!/bin/bash

set -o errexit

declare _path_="$(pwd)"
declare status="0"

echo ${_path_} | grep google-cloud > /dev/null 2>&1 || status="1"

if [[ ${status} = "0" ]]; then
	if [[ -z ${TRAVIS_gcp_token} ]]; then
		echo "Error: You need declare and export TF_VAR_gcp_token variable"
		exit 1
	fi
    echo ${TRAVIS_gcp_token} | base64 -d > /tmp/google-cloud-account.json
    echo ${TF_VAR_gcp_token} | jq . > /tmp/google-cloud-account.json
fi

/bin/bash -c "${*}"
