#!/usr/bin/bash

terraform destroy -var-file=environment.tfvars -auto-approve

rm ./scripts/keys/*