output "bucket" {
  description = "bucket itself"
  value = google_storage_bucket.gcs_bucket
}

output "bucket_name" {
  description = "bucket name"
  value = google_storage_bucket.gcs_bucket.name
}
