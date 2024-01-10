output "lb_ip" {
  value       = "LB IP: http://${module.gce-lb-http.external_ip}"
  description = "IP FOR LB"
}