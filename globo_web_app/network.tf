
#######################################
#RESOURCES
#######################################
# VPC #
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.gcp_project
  network_name = "${local.naming_prefix}-vpc-network"
  routing_mode = "GLOBAL"

  subnets = [for subnet in range(var.vpc_subnet_count) : {
    subnet_name = "${local.naming_prefix}-subnet-${var.gcp_region[subnet]}"
    subnet_ip   = cidrsubnet(var.gcp_vpcs_subnet_ip_cidr_range, 8, subnet + 1)
  subnet_region = var.gcp_region[subnet] }]

  ingress_rules = [{
    name = "${local.naming_prefix}-firewall"
    allow = [{
      protocol = "tcp"
      ports    = var.gcp_ports_firewall_rule
    }]
    source_ranges = ["35.235.240.0/20"]
    priority      = 999
    }
  ]
}

# ROUTERS
resource "google_compute_router" "groups" {
  count   = var.vpc_subnet_count
  name    = "${local.naming_prefix}-router-gw-group${count.index}"
  network = module.vpc.network_self_link
  #network = google_compute_network.vpc_network.self_link
  region = var.gcp_region[count.index]
}
# CLOUD NATS
module "cloud-nat-groups" {
  count      = var.vpc_subnet_count
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 2.2"
  router     = google_compute_router.groups[count.index].name
  project_id = var.gcp_project
  region     = var.gcp_region[count.index]
  name       = "${local.naming_prefix}-cloud-nat-group${count.index}"
}

# HTTP LB
module "gce-lb-http" {
  source      = "terraform-google-modules/lb-http/google"
  version     = "~> 10.0"
  name        = "${local.naming_prefix}-${var.network_prefix}"
  project     = var.gcp_project
  target_tags = concat(module.vpc.subnets_names[*], module.cloud-nat-groups[*].router_name)
  #target_tags = concat(google_compute_subnetwork.vpc_subnets[*].name , module.cloud-nat-groups[*].router_name)
  firewall_networks = [module.vpc.network_name]
  #firewall_networks = [google_compute_network.vpc_network.name]

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

      iap_config = {
        enable = false
      }

      groups = [for m in module.migs[*].instance_group : { group = m }]

    }
  }
}
# [END cloudloadbalancing_ext_http_gce]



#######################################
#DATA SOURCE
#######################################
/*data "google_compute_zones" "available" {
}*/


/*
# VPC
resource "google_compute_network" "vpc_network" {
  name                    = "${local.naming_prefix}-vpc-network"
  auto_create_subnetworks = false
  mtu                     = var.gcp_mtu
}
# SUBNETS
resource "google_compute_subnetwork" "vpc_subnets" {
  count = var.vpc_subnet_count
  name          = "${local.naming_prefix}-subnet${count.index}"
  ip_cidr_range = cidrsubnet(var.gcp_vpcs_subnet_ip_cidr_range,8,count.index+1)
  network       = google_compute_network.vpc_network.id
  region        = var.gcp_region[count.index]
  #private_ip_google_access = true
}

# FIREWALL
resource "google_compute_firewall" "firewall" {
  name    = "${local.naming_prefix}-firewall"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = var.gcp_ports_firewall_rule
  }
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  priority      = 999
}
*/







