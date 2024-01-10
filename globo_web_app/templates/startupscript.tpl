#! /bin/bash
apt update
apt install -y apache2
sudo rm /var/www/html/index.html
gsutil cp gs://${gcs_bucket_name}/website/index.html /var/www/html/
gsutil cp gs://${gcs_bucket_name}/website/prometheus.png /var/www/html/
  