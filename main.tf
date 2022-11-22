module "network" {
  source       = "github.com/cj1138/terraform-modules/gcp-custom-network"
  project      = var.project
  network      = var.network
  subnet       = var.subnet
  subnet_range = var.subnet_range
  region       = var.region
}

module "firewall-internal" {
  source = "github.com/cj1138/terraform-modules/gcp-firewall-allow"
  firewall_rule = "allow-internal"
  network = var.network
  protocol = var.protocol
  ports = var.ports
  tags = var.tags
  ranges = var.ranges
}
