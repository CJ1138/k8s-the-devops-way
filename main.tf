// Setup GCP Provider
provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

// Create network, subnet and firewall rules
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 6.0"

  project_id   = var.project
  network_name = var.network
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = var.subnet
      subnet_ip     = "10.240.0.0/24"
      subnet_region = var.region
    }
  ]

  firewall_rules = [{
    name                    = "kubernetes-the-hard-way-allow-internal"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["10.240.0.0/24", "10.200.0.0/16"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = null
      }, {
      protocol = "udp"
      ports    = null
      }, {
      protocol = "icmp"
      ports    = null
    }]
    deny       = []
    log_config = null
    }, {
    name                    = "kubernetes-the-hard-way-allow-external"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
      }, {
      protocol = "tcp"
      ports    = ["6443"]
      }, {
      protocol = "icmp"
      ports    = null
    }]
    deny       = []
    log_config = null
  }]
}

// Create static IP address
resource "google_compute_address" "ip_address" {
  name = "kubernetes-the-hard-way"
}

// Create controller nodes
resource "google_compute_instance" "controllers" {
  depends_on     = [module.vpc]
  project        = var.project
  count          = 3
  name           = "controller-${count.index}"
  machine_type   = "e2-standard-2"
  zone           = var.zone
  can_ip_forward = true
  tags           = ["kubernetes-the-hard-way", "controller"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  network_interface {
    subnetwork         = var.subnet
    subnetwork_project = var.project
    network_ip         = "10.240.0.1${count.index}"
    access_config {

    }
  }

  service_account {
    email  = null
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
}

// Create worker nodes
resource "google_compute_instance" "workers" {
  depends_on     = [module.vpc]
  project        = var.project
  count          = 3
  name           = "worker-${count.index}"
  machine_type   = "e2-standard-2"
  zone           = var.zone
  can_ip_forward = true
  tags           = ["kubernetes-the-hard-way", "worker"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  network_interface {
    subnetwork         = var.subnet
    subnetwork_project = var.project
    network_ip         = "10.240.0.2${count.index}"
    access_config {

    }
  }

  service_account {
    email  = null
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
  }
}

resource "google_compute_http_health_check" "default" {
  name         = "kubernetes"
  description  = "Kubernetes Health Check"
  host         = "kubernetes.default.svc.cluster.local"
  request_path = "/healthz"
}

resource "google_compute_firewall" "default" {
  name    = "kubernetes-the-hard-way-allow-health-check"
  depends_on     = [module.vpc]
  network = var.network

  allow {
    protocol = "tcp"
  }
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
}

resource "google_compute_target_pool" "default" {
  name = "kubernetes-target-pool"
  depends_on = [google_compute_http_health_check.default]
  instances = [
    "${var.zone}/controller-0",
    "${var.zone}/controller-1",
    "${var.zone}/controller-2"
  ]
  health_checks = [
    "kubernetes"
  ]
}

resource "google_compute_forwarding_rule" "fwd_rule" {
  provider = google-beta
  name     = "kubernetes-forwarding-rule"
  ip_address = google_compute_address.ip_address.address
  port_range    = "6443"
  target   = google_compute_target_pool.default.id
  region   = var.region
  
}

resource "google_compute_route" "default" {
  depends_on = [
    module.vpc
  ]
  count = 3
  name        = "kubernetes-route-10-200-${count.index}-0-24"
  network     = var.network
  next_hop_ip = "10.240.0.2${count.index}"
  dest_range  = "10.200.${count.index}.0/24"
}