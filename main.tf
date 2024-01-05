###
#PROVIDERS
###
provider "google" {
  project = "brauss2024"
  region = "us-central1" 
}

###
#DATA skipped at the momment
###


###
#RESOURCES
###

# VPC
resource "google_compute_network" "vpc_network" {
    name = "vpc_network"
    auto_create_subnetworks = false
    mtu = 1460  
}

# SUBNET
resource "google_compute_subnetwork" "vpc_subnet" {
    name = "subnet"
    ip_cidr_range = "10.0.0.0/24"
    network = google_compute_network.vpc_network.id
}

# FIREWALL
resource "google_compute_firewall" "firewall" {
  name = "myfirewall"
  network = google_compute_subnetwork.vpc_subnet
  allow {
    protocol = "tcp"
    ports = ["22", "8080"]
  }
  source_tags = ["web"]
}

# VM GCE
resource "google_compute_instance" "default" {
  name = "my-instance"
  machine_type = "e2-micro"
  zone = "us-central1-a"
  tags = ["web"]
  boot_disk {
    initialize_params {
      image= "debian-cloud/debian-11"        
      labels = {
        mylabel = "foo"
      }
    }
  }
  network_interface {
    network = google_compute_network.vpc_network
    subnetwork = google_compute_subnetwork.vpc_subnet
  }
  metadata_startup_script = "echo hi > /test.txt"
  service_account {
    email = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}





