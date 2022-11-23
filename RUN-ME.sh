#!/usr/bin/bash
#      _          _      _       _                            _            _     
#  ___| |__  _ __(_)___ (_) ___ | |__  _ __  ___  ___  _ __  | |_ ___  ___| |__  
# / __| '_ \| '__| / __|| |/ _ \| '_ \| '_ \/ __|/ _ \| '_ \ | __/ _ \/ __| '_ \ 
#| (__| | | | |  | \__ \| | (_) | | | | | | \__ \ (_) | | | || ||  __/ (__| | | |
# \___|_| |_|_|  |_|___// |\___/|_| |_|_| |_|___/\___/|_| |_(_)__\___|\___|_| |_|
#                     |__/                                                       

# Bash script to run all required commands and processes to implement kelseyhightower/kubernetes-the-hard-way
# on Google Cloud Platform

# Error handling (with thanks to https://github.com/HariSekhon)
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Provision the infrastructure
terraform apply -var-file=environment.tfvars -auto-approve

# Create PKI resources
./scripts/pki/ca-config.sh
./scripts/pki/admin-cert.sh
./scripts/pki/kublet-certs.sh
./scripts/pki/kube-controller-cert.sh
./scripts/pki/kube-proxy-cert.sh
./scripts/pki/kube-scheduler-cert.sh
./scripts/pki/api-server-cert.sh
./scripts/pki/service-account-cert.sh
cd ./keys

# Wait to ensure IAP is activated on the VMs
sleep 1m

# Deplot keys to VMs
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done

cd ~