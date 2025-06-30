output "instance_id" {
  description = "The ID of the VM instance"
  value       = google_compute_instance.vm_instance.id
  
}
output "instance_public_ip" {
  description = "The public IP address of the VM instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
  
}