output "gcp_vm_ip" {
  value       = "https://${google_compute_instance.default.name}"
  description = "IP for VM created"
}