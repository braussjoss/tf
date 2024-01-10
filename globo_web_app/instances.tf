module "mig_templates" {
  count        = var.mig_count
  source       = "terraform-google-modules/vm/google//modules/instance_template"
  version      = "~> 7.9"
  network      = google_compute_network.vpc_network.self_link
  subnetwork   = google_compute_subnetwork.vpc_subnets[count.index].self_link
  machine_type = var.gcp_vm_machine_type
  source_image = var.gcp_vm_image
  disk_size_gb = 10
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix    = google_compute_network.vpc_network.name
  startup_script = templatefile("${path.module}/templates/startupscript.tpl",{
    gcs_bucket_name = google_storage_bucket.gcs_bucket.name
  })
  /*<<EOF
  #! /bin/bash
  apt update
  apt install -y apache2
  sudo rm /var/www/html/index.html
  gsutil cp gs://${google_storage_bucket.gcs_bucket.name}/website/index.html /var/www/html/
  gsutil cp gs://${google_storage_bucket.gcs_bucket.name}/website/prometheus.png /var/www/html/
  EOF*/
  tags = concat([
    google_compute_network.vpc_network.name,
  google_compute_router.groups[count.index].name], var.gcp_source_tags)
}

module "migs" {
  count = var.mig_count
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 7.9"
  instance_template = module.mig_templates[count.index].self_link
  region            = var.gcp_region[count.index % var.vpc_subnet_count]
  hostname          = google_compute_network.vpc_network.name
  mig_name          = "${local.naming_prefix}-mig-${count.index}-${var.gcp_region[count.index]}"
  target_size       = 1
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.vpc_subnets[count.index].self_link
  depends_on = [google_storage_bucket_object.website_content]
}

# VM1 GCE #
/*
resource "google_compute_instance" "default1" {
  name         = "my-instance1"
  machine_type = var.gcp_vm_machine_type
  zone         = data.google_compute_zones.available.names[0]
  tags         = var.gcp_source_tags
  labels       = local.common_tags
  boot_disk {
    initialize_params {
      image = var.gcp_vm_image
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet1.id
    access_config {}
  }
  metadata_startup_script = <<EOF
  #! /bin/bash
  apt update
  apt install -y apache2
  sudo rm /var/www/html/index.html
  echo '<html><body><h2>Welcome to your custom website 1.</h2><h3>Created with a direct input startup script!</h3></body></html>' > /var/www/html/index.html
  EOF
}
*/

# VM2 GCE #
/*
resource "google_compute_instance" "default2" {
  name         = "my-instance2"
  machine_type = var.gcp_vm_machine_type
  zone         = data.google_compute_zones.available.names[1]
  tags         = var.gcp_source_tags
  labels       = local.common_tags
  boot_disk {
    initialize_params {
      image = var.gcp_vm_image
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet2.id
    access_config {}
  }
  metadata_startup_script = <<EOF
  #! /bin/bash
  apt update
  apt install -y apache2
  sudo rm /var/www/html/index.html
  echo '<html><body><h2>Welcome to your custom website 2.</h2><h3>Created with a direct input startup script!</h3></body></html>' > /var/www/html/index.html
  EOF
}
*/


/*
module "mig_template1" {
  source       = "terraform-google-modules/vm/google//modules/instance_template"
  version      = "~> 7.9"
  network      = google_compute_network.vpc_network.self_link
  subnetwork   = google_compute_subnetwork.vpc_subnet1.self_link
  machine_type = var.gcp_vm_machine_type
  source_image = var.gcp_vm_image
  disk_size_gb = 10
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix    = google_compute_network.vpc_network.name
  startup_script = <<EOF
  #! /bin/bash
  apt update
  apt install -y apache2
  sudo rm /var/www/html/index.html
  gsutil cp gs://${google_storage_bucket.gcs_bucket.name}/website/index.html /var/www/html/
  gsutil cp gs://${google_storage_bucket.gcs_bucket.name}/website/prometheus.png /var/www/html/
  EOF
  tags = concat([
    google_compute_network.vpc_network.name,
  google_compute_router.group1.name], var.gcp_source_tags)
}

module "mig1" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 7.9"
  instance_template = module.mig_template1.self_link
  region            = var.gcp_region[0]
  hostname          = google_compute_network.vpc_network.name
  mig_name          = "mig1"
  target_size       = 1
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.vpc_subnet1.self_link
  depends_on = [ google_storage_bucket_object.index, google_storage_bucket_object.picture ]
}


module "mig_template2" {
  source       = "terraform-google-modules/vm/google//modules/instance_template"
  version      = "~> 7.9"
  network      = google_compute_network.vpc_network.self_link
  subnetwork   = google_compute_subnetwork.vpc_subnet2.self_link
  machine_type = var.gcp_vm_machine_type
  source_image = var.gcp_vm_image
  disk_size_gb = 10
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix    = google_compute_network.vpc_network.name
  startup_script = <<EOF
  #! /bin/bash
  apt update
  apt install -y apache2
  sudo rm /var/www/html/index.html
  echo '<html><body><h2>Welcome to your custom website 2.</h2><h3>Created with a direct input startup script!</h3></body></html>' > /var/www/html/index.html
  EOF
  tags = concat([
    google_compute_network.vpc_network.name,
  google_compute_router.group2.name], var.gcp_source_tags)
}

module "mig2" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 7.9"
  instance_template = module.mig_template2.self_link
  region            = var.gcp_region[1]
  hostname          = google_compute_network.vpc_network.name
  mig_name          = "mig2"
  target_size       = 1
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.vpc_subnet2.self_link
  depends_on = [ google_storage_bucket_object.index, google_storage_bucket_object.picture ]
}
*/

