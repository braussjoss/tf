### GLOBO WEB APP#####################
#PROVIDERS
#######################################
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

#######################################
#RESOURCES
#######################################

# VPC
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = false
  mtu                     = var.gcp_mtu
}

# SUBNET
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "subnet"
  ip_cidr_range = var.gcp_ip_cidr_range
  network       = google_compute_network.vpc_network.id
}

# FIREWALL
resource "google_compute_firewall" "firewall" {
  name    = "myfirewall"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = var.gcp_ports_firewall_rule
  }
  source_tags = var.gcp_source_tags
}

# VM GCE
resource "google_compute_instance" "default" {
  name         = "my-instance"
  machine_type = var.gcp_vm_machine_type
  zone         = var.gcp_zone
  tags         = var.gcp_source_tags
  labels       = local.common_tags
  boot_disk {
    initialize_params {
      image = var.gcp_vm_image
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id
  }
  metadata_startup_script = <<EOF
  #! /bin/bash
  apt update
  apt install -y apache2
  sudo rm /var/www/html/index.html
  echo '<html><body><h2>Welcome to your custom website.</h2><h3>Created with a direct input startup script!</h3></body></html>' > /var/www/html/index.html
  EOF
  
  #echo hi > /test.txt
  #service_account {
  #  email = google_service_account.default.email
  #  scopes = ["cloud-platform"]
  #}
}





