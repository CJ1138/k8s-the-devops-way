# K8s The DevOps Way

PLEASE NOTE THIS REPO IS A WiP!

A fully automated deployment of Kelsey Hightowers's "Kubernetes The Hard Way" tutorial. Created for my own learning purposes, the intention is to extend the purpose of the original tutorial (understanding each task required to bootstrap a Kubernetes cluster) by additionally demonstrating how to do that on Google Cloud Pkatform with automation tools (Terraform, Ansible, shell scripting), and then applying an ongoing monitoring solution.

Sections of the original tutorial currently covered by this repo:

- [x] Installing the Client Tools
- [x] Provisioning Compute Resources
- [x] Provisioning the CA and Generating TLS Certificates
- [x] Generating Kubernetes Configuration Files for Authentication
- [x] Generating the Data Encryption Config and Key
- [x] Bootstrapping the etcd Cluster
- [x] Bootstrapping the Kubernetes Control Plane
- [x] Bootstrapping the Kubernetes Worker Nodes
- [x] Configuring kubectl for Remote Access
- [x] Provisioning Pod Network Routes
- [x] Deploying the DNS Cluster Add-on
- [ ] Smoke Test
- [x] Cleaning Up

## Instructions

This project assumes that the [prequisites](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md) from the original tutorial have been met.

Install client tools (Linux only): `$ ./scripts/client-tools-linux.sh`

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

[Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

(For ease of setup, I have configured Ansible to use IAP tunnelling and Dynamic Inventory. It should work out of the box but help is [here](https://docs.ansible.com/ansible/latest/collections/google/cloud/gcp_compute_inventory.html) if additional dependencies seem to be required.)

Run `terraform init`

Change name of GCP Project (and, optionally, Region / Zone) in `./environment.tfvars`.

Change name of GCP Project in `./ansible/ansible.cfg`.

Run `./RUN_ME.sh`

In the current incarnation of this project, the above actions will:

- Provision the required VMs in GCP
- Provision a Certificate Authority & generate the required TLS certs
- Generate the kubeconfig files
- Generate data encryption config and key files
- Correctly disperse all created key / config files to the VMs
- Bootstrap an etcd cluster
- Bootstrap a Kubernetes control plane
- Bootstrap 3 Kubernetes worker nodes
- Configure kubectl for Remote Access
- Provision Pod Network Routes
- Deploy the DNS Cluster Add-on

Running `./scripts/clean-up.sh` will delete all resources on GCP and any files created dynamically by the above process.