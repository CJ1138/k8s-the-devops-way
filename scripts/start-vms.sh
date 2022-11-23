#/usr/bin/bash
gcloud compute instances start $(gcloud compute instances list | awk '{print $1}'| tail -n+2)