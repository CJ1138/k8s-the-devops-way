#!/usr/bin/bash
# Error handling (with thanks to https://github.com/HariSekhon)
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "This will delete local dynamically created local resources and all provisioned resources in the current GCP project:"

echo $(gcloud config list project)

echo "Really proceed? y/n"

read confirm

if [ $confirm = "y" ] || [ $confirm = "Y" ]
then
    terraform destroy -var-file=environment.tfvars -auto-approve
    rm ./keys/*
else
    echo "Aborted"
fi