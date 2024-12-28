variable "region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "key-name" {
  description = "value of the key name"
}

variable "ubuntu-ami" {
  description = "The AMI ID for the Ubuntu Server"
}