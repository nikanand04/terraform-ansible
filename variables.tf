variable "ami_id" {
    type = string
    default = "ami-0f2eac25772cd4e36"
}

variable "instance_type" {
    type = string
    default = "t3.medium"
}

variable "availability_zones" {
  description = "AZ in which all the resources will be deployed"
  default = "ap-southeast-1a"
}

variable "environment" {
  description = "Deployment Environment"
  default = "dev"
}

variable "owner" {
  description = "Owner of resource"
  default     = "zhihao.pang@hashicorp.com"
}

variable "purpose" {
  description = "Purpose of resource"
  default     = "testing"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0c224799108be2af4"
}

variable "subnet_id" {
  description = "Public Subnet ID"
  default     = "subnet-000a10782db3339bf"
}

variable "region" {
  description = "Region in which the resource will be launched"
   default    = "ap-southeast-1"
}

variable "hcp_bucket" {
  description = "HCP Packer bucket name"
  default = "app1-ubuntu"
}

variable "hcp_channel" {
  description = "HCP Packer channel name"
  default = "staging"
}

variable "version_name" {
  type    = string
  default = "1.0.0"
}

