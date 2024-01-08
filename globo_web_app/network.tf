### GLOBO WEB APP#####################
#PROVIDERS
#######################################
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region[0]
}


#######################################
#DATA SOURCE
#######################################
data "google_compute_zones" "available" {
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

# SUBNET 1
resource "google_compute_subnetwork" "vpc_subnet1" {
  name                     = "subnet1"
  ip_cidr_range            = var.gcp_vpcs_subnet_ip_cidr_range[0]
  network                  = google_compute_network.vpc_network.id
  region                   = var.gcp_region[0]
  #private_ip_google_access = true
}
# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
# ROUTER 1
resource "google_compute_router" "group1" {
  name    = "router-gw-group1"
  network = google_compute_network.vpc_network.self_link
  region  = var.gcp_region[0]
}
# CLOUD NAT 1
module "cloud-nat-group1" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 2.2"
  router     = google_compute_router.group1.name
  project_id = var.gcp_project
  region     = var.gcp_region[0]
  name       = "cloud-nat-group1"
}


# SUBNET 2
resource "google_compute_subnetwork" "vpc_subnet2" {
  name                     = "subnet2"
  ip_cidr_range            = var.gcp_vpcs_subnet_ip_cidr_range[1]
  network                  = google_compute_network.vpc_network.id
  region                   = var.gcp_region[1]
  #private_ip_google_access = true
}
# ROUTER 2
resource "google_compute_router" "group2" {
  name    = "router-gw-group2"
  network = google_compute_network.vpc_network.self_link
  region  = var.gcp_region[1]
}
# CLOUD NAT 2
module "cloud-nat-group2" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 2.2"
  router     = google_compute_router.group2.name
  project_id = var.gcp_project
  region     = var.gcp_region[1]
  name       = "cloud-nat-group2"
}


# [START cloudloadbalancing_ext_http_gce]

module "gce-lb-http" {
  source  = "terraform-google-modules/lb-http/google"
  version = "~> 10.0"
  name    = var.network_prefix
  project = var.gcp_project
  target_tags = [
    google_compute_subnetwork.vpc_subnet1.name,
    module.cloud-nat-group1.router_name,
    google_compute_subnetwork.vpc_subnet2.name,
    module.cloud-nat-group2.router_name
  ]
  firewall_networks = [google_compute_network.vpc_network.name]

  backends = {
    default = {

      protocol    = "HTTP"
      port        = 80
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/"
        port         = 80
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = module.mig1.instance_group
        },
        {
          group = module.mig2.instance_group
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
}
# [END cloudloadbalancing_ext_http_gce]


# FIREWALL
resource "google_compute_firewall" "firewall" {
  name    = "myfirewall"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = var.gcp_ports_firewall_rule
  }
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  priority      = 999
}








