#PROVIDERS
#######################################

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region[0]
}

provider "random" {
  # Configuration options
}