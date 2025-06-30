variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  
}
variable "selected_ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  
}
variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  
}
variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
  
}

variable "instance_name" {
  description = "The name tag for the EC2 instance"
  type        = string
  
}