project      = "learn-gcp-cj"
network      = "kubernetes-the-hard-way"
subnet       = "kubernetes"
subnet_range = "10.240.0.0/24"
region       = "europe-west2"

protocol = "tcp"
ports = ["80", "8080"]
tags = ["test"]
ranges = ["0.0.0.0/0"]