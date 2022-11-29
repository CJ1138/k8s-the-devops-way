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

export project=$(gcloud config list --format 'value(core.project)')

# Provision the infrastructure
terraform apply -var-file=environment.tfvars -auto-approve

# Get public IP address
export KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

export KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cd scripts/pki

# Create PKI resources
./ca-config.sh
./admin-cert.sh
./kublet-certs.sh
./kube-controller-cert.sh
./kube-proxy-cert.sh
./kube-scheduler-cert.sh
./api-server-cert.sh
./service-account-cert.sh

# Wait to ensure IAP is activated on the VMs
sleep 1m

# Deploy keys to VMs
cd ../../keys

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done

# Get public IP address
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

# Generate kubeconfig files

../scripts/kubeconfigs/generate-configs.sh

cd ../configs

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done

# Generate encryption key
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# Create encryption config file
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

# Disperse encryption config to controllers
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done

cd ../ansible

ansible-playbook playbook.yml

cd ..

curl --cacert ./keys/ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version

gcloud compute ssh controller-0 \
  --command "kubectl get nodes --kubeconfig admin.kubeconfig"

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem

kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin

kubectl config use-context kubernetes-the-hard-way

kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns-1.8.yaml

kubectl get pods -l k8s-app=kube-dns -n kube-system