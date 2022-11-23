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
module "external_address" {
  source       = "terraform-google-modules/address/google"
  version      = "~> 3.1"
  project_id   = var.project
  region       = var.region
  address_type = "EXTERNAL"
  names = [
    "kubernetes-the-hard-way"
  ]
}

// Create controller nodes
resource "google_compute_instance" "controllers" {
  depends_on = [module.vpc]
  project = var.project
  count = 3
  name         = "controller-${count.index}"
  machine_type = "e2-standard-2"
  zone         = var.zone
  can_ip_forward = true
  tags = ["kubernetes-the-hard-way","controller"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size = 200
    }
  }

  network_interface {
    subnetwork = var.subnet
    subnetwork_project = var.project
    network_ip = "10.240.0.1${count.index}"
  }

  service_account {
    email  = null
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }
}

// Create worker nodes
resource "google_compute_instance" "workers" {
  depends_on = [module.vpc]
  project = var.project
  count = 3
  name         = "worker-${count.index}"
  machine_type = "e2-standard-2"
  zone         = var.zone
  can_ip_forward = true
  tags = ["kubernetes-the-hard-way","worker"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size = 200
    }
  }

  network_interface {
    subnetwork = var.subnet
    subnetwork_project = var.project
    network_ip = "10.240.0.2${count.index}"
  }

  service_account {
    email  = null
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }

  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
  }
}