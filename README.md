# K8s The Devops Way

PLEASE NOTE THIS REPO IS A WIP!

An fully automated deployment of Kelsey Hightowers's "Kubernetes The Hard Way" tutorial. Created for my own learning purposes, the intention is to extend the purpose of the origin tutorial (understanding each task required to bootstrap a Kubernetes cluster) by additionally demonstrating how to do that with automation and monitoring tools.

Sections of the original tutorial currently covered by this repo:

- [x] Installing the Client Tools
- [x] Provisioning Compute Resources
- [x] Provisioning the CA and Generating TLS Certificates
- [ ] Generating Kubernetes Configuration Files for Authentication
- [ ] Generating the Data Encryption Config and Key
- [ ] Bootstrapping the etcd Cluster
- [ ] Bootstrapping the Kubernetes Control Plane
- [ ] Bootstrapping the Kubernetes Worker Nodes
- [ ] Configuring kubectl for Remote Access
- [ ] Provisioning Pod Network Routes
- [ ] Deploying the DNS Cluster Add-on
- [ ] Smoke Test
- [ ] Cleaning Up

## Instructions

This project assumes that the [prequisites](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md) from the original tutorial have been met.

Install client tools (Linux only): `$ ./scripts/client-tools-linux.sh`

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Run `terraform init`

Run `./RUN_ME.sh`

In the current incarnation of this project, the above actions will provision all the required resources in GCP, provision a Certificate Authority & generate the required TLS certs, then correctly disperse the created files to the new VMs.