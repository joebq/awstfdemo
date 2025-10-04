variable "aws_region" {
  type = string
  description = "AWS Region to use for main resouces"
  default = "east-us-1"
  
}

variable "vcp_cidr" {
  type = string
  description = "Main VPC CIDR value"
  default = "10.0.0.0/16"
  
}

variable "subnet_cidr" {
  type = string
  description = "Subnet CIDR Value"
  default = "10.0.0.0/24"
  
}

variable "map_public_ip" {
  type = bool
  description = "Set the Mapping of public ip on launch"
  
}

variable "http_port" {
  type = number
  description = "HTTP Port Number"
  
}

variable "instance" {
  type = string
  description = "type of EC2 instance for the web machine"
  
}