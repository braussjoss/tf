variable "gcp_project" {
  type        = string
  description = "GCP Project to work on"
  default     = "brauss2024"
}

variable "gcp_region" {
  type        = list(string)
  description = "Region in GCP to create the project"
  default     = ["us-central1", "us-west1"]
}

variable "gcp_zone" {
  type        = string
  description = "Zone in GCP to create the project"
  default     = "us-central1-a"
}

variable "gcp_mtu" {
  type        = number
  description = "Max Lat allowed"
  default     = 1460
}

variable "gcp_vpcs_subnet_ip_cidr_range" {
  type        = string
  description = "IP Range for subnets in VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_subnet_count" {
  type        = number
  description = "Number of subnets to create"
  default     = 2
}

variable "mig_count" {
  type        = number
  description = "Number of migs to be created"
  default     = 2 #Remember to update gcp_region[] var
}

variable "gcp_source_tags" {
  type        = list(string)
  description = "Source tags to apply Firewall rule"
  default     = ["web", "http-server", "https-server"]
}

variable "gcp_ports_firewall_rule" {
  type        = list(string)
  description = "Ports to be allowed in tcp"
  default     = ["22", "8080", "80", "443"]
}

variable "gcp_vm_machine_type" {
  type        = string
  description = "VM Machine type"
  default     = "e2-micro"
}

variable "gcp_vm_image" {
  type        = string
  description = "VM image"
  default     = "projects/debian-cloud/global/images/family/debian-11"
}

variable "network_prefix" {
  type    = string
  default = "multi-mig-lb-http"
}

#company
variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "globo-web-app"
}

#project
variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

#billing code
variable "billing_code" {
  type        = string
  description = "Billing code name for resource tagging"
}

variable "naming_prefix" {
  type        = string
  description = "Namiong prefix for all resources"
  default     = "globo-web-app"
}

variable "environment" {
  type        = string
  description = "Environment for the resources"
  default     = "dev"
}