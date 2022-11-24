#!/usr/bin/bash
#      _          _      _       _                            _            _     
#  ___| |__  _ __(_)___ (_) ___ | |__  _ __  ___  ___  _ __  | |_ ___  ___| |__  
# / __| '_ \| '__| / __|| |/ _ \| '_ \| '_ \/ __|/ _ \| '_ \ | __/ _ \/ __| '_ \ 
#| (__| | | | |  | \__ \| | (_) | | | | | | \__ \ (_) | | | || ||  __/ (__| | | |
# \___|_| |_|_|  |_|___// |\___/|_| |_|_| |_|___/\___/|_| |_(_)__\___|\___|_| |_|
#                     |__/                                                       
# 
# Deletes all resources in k8s-the-devops-way project

# Error handling (with thanks to https://github.com/HariSekhon)
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

project=$(gcloud config list --format 'value(core.project)')

echo "This will delete:"
echo "- The contents of the /keys folder"
echo "- The contents of the /configs folder"
echo "- All provisioned resources in GCP project \"$project\""
echo ""
echo "Really proceed? y/n"

read confirm

if [ $confirm = "y" ] || [ $confirm = "Y" ]
then
    terraform destroy -var-file=environment.tfvars -auto-approve
    rm keys/*
    rm configs/*
else
    echo "Aborted"
fi