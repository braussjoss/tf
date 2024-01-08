output "gcp_mig1" {
  value       = "${module.mig1.instance_group}   --  ${module.mig1.self_link}"
  description = "MIG INFO"
}

output "lb_ip"{
  value = "LB IP: http://${module.gce-lb-http.external_ip}"
  description = "IP FOR LB"
}