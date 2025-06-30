variable "subscription_id" {
  description = "The Azure subscription ID to deploy resources in"
  type        = string
  
}
variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  
}

variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
}

variable "vm_name" {
  description = "The name of the Azure VM"
  type        = string
}

variable "vm_size" {
  description = "The size of the Azure VM"
  type        = string
  
}
variable "admin_username" {
  description = "The username of the Azure VM"
  type        = string
  
}
variable "admin_password" {
  description = "The password for the Azure VM admin user"
  type        = string
  sensitive   = true
  
}
variable "image_publisher" {
  description = "The publisher of the Azure VM image"
  type        = string
}

variable "image_offer" {
  description = "The offer of the Azure VM image"
  type        = string
}

variable "image_sku" {
  description = "The SKU of the Azure VM image"
  type        = string
  
}

