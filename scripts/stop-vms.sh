#!/usr/bin/bash
gcloud compute instances stop $(gcloud compute instances list | awk '{print $1}'| tail -n+2)