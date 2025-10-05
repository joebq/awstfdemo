# AWS Region Configuration
variable "aws_region" {
  type        = string
  description = "AWS Region to use for main resouces"
  default     = "us-east-1"

}

# VPC Network Configuration
variable "vcp_cidr" {
  type        = string
  description = "Main VPC CIDR value"
  default     = "10.0.0.0/16"

}

# Subnet Configuration
variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR Value"
  default     = "10.0.0.0/24"

}

# Public IP Mapping Configuration
variable "map_public_ip" {
  type        = bool
  description = "Set the Mapping of public ip on launch"
  default     = true

}

# Network Port Configuration
variable "http_port" {
  type        = number
  description = "HTTP Port Number"

}

# EC2 Instance Configuration
variable "instance" {
  type        = string
  description = "type of EC2 instance for the web machine"

}

# Company Configuration
variable "company" {
  type        = string
  description = "Company name"
  default     = "Globalmantics"

}

# Project Configuration
variable "project" {
  type        = string
  description = "type of the project"

}

# Environment Configuration
variable "environment" {
  type        = string
  description = "The environment to be deployed (prod, dev, staging)"

}

# Billing Configuration
variable "billing_code" {
  type        = string
  description = "the billing code for the project"

}