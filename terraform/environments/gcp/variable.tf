variable "project_id" {
  description = "The GCP project ID to deploy resources in"
  type        = string
  
}
variable "region" {
  description = "The GCP region to deploy resources in"
  type        = string
  
}
variable "zone" {
  description = "The GCP zone to deploy resources in"
  type        = string
  
}
variable "selected_image" {
  description = "The image to use for the VM instance"
  type        = string
  
}
variable "instance_type" {
  description = "The machine type for the VM instance"
  type        = string
  
}
variable "instance_name" {
  description = "The name of the VM instance"
  type        = string
  
}