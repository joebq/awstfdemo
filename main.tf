# Terraform configuration for AWS infrastructure
# This configuration creates a VPC with public subnet, security group, and related resources

# Terraform configuration block
# Specifies minimum Terraform version and required providers
terraform {
  required_version = ">= 1.13.0" # Minimum Terraform version required
  required_providers {
    aws = {
      source  = "hashicorp/aws" # AWS provider from HashiCorp
      version = "~>6.0"         # AWS provider version constraint
    }

  }
}

# AWS Provider configuration
# Configures the AWS provider with the target region
provider "aws" {
  region = var.aws_region # Deploy resources in US East (N. Virginia) region

}

# Data source to fetch the latest Amazon Linux 2 AMI ID
# Uses AWS Systems Manager Parameter Store to get the most recent AMI
data "aws_ssm_parameter" "aws_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Main VPC (Virtual Private Cloud)
# Creates an isolated network environment in AWS
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vcp_cidr # IP address range for the VPC (65,536 IP addresses)
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = lower("${local.naming_prefix}-vpc") })
}

# Internet Gateway for the VPC
# Provides internet connectivity to resources in public subnets
resource "aws_internet_gateway" "ig" {

  vpc_id = aws_vpc.main_vpc.id # Attach to the main VPC
  tags   = merge(local.common_tags, { Name = lower("${local.naming_prefix}-ig") })

}

# Public subnet within the main VPC
# Subnet for resources that need internet access (web servers, load balancers, etc.)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id # Reference to the main VPC
  cidr_block              = var.subnet_cidr     # Subnet IP range (256 IP addresses)
  map_public_ip_on_launch = var.map_public_ip

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-sb") })

}

# Security Group for public subnet resources
# Acts as a virtual firewall controlling inbound and outbound traffic
resource "aws_security_group" "sg_public" {
  name        = "${local.naming_prefix}-sg-allow_internet"
  description = "Allow Internet Access"
  vpc_id      = aws_vpc.main_vpc.id # Associate with the main VPC

  # # Inbound rule - Allow SSH traffic from anywhere
  # ingress {
  #   from_port   = 22            # SSH port (note: SSH uses port 22, not 21)
  #   to_port     = 22            # SSH port
  #   protocol    = "tcp"         # TCP protocol
  #   cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (consider restricting for security)
  # }

  # Outbound rule - Allow HTTP traffic to anywhere
  ingress {
    from_port   = var.http_port # HTTP port
    to_port     = var.http_port # HTTP port
    protocol    = "tcp"         # TCP protocol
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to anywhere on the internet
  }

  # Inbound rule - Allow all traffic from anywhere (WARNING: Very permissive)
  # Note: This is not recommended for production environments
  egress {
    from_port   = 0             # All ports
    to_port     = 0             # All ports
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere on the internet

  }

  # Lifecycle rule to create new security group before destroying old one
  # Prevents dependency issues during updates
  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags

}

# Custom Route Table for public subnet
# Defines routing rules for network traffic within the VPC
resource "aws_route_table" "route_tb" {
  vpc_id = aws_vpc.main_vpc.id # Associate with the main VPC

  # Route configuration for public subnet traffic
  route {
    cidr_block = "0.0.0.0/0"                # Traffic destined for public subnet
    gateway_id = aws_internet_gateway.ig.id # Route through internet gateway
  }

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-rt") })

}

# Route Table Association
# Links the public subnet to the custom route table
# This enables internet access for resources in the public subnet
resource "aws_route_table_association" "route_tb_association" {
  subnet_id      = aws_subnet.public_subnet.id # Public subnet to associate
  route_table_id = aws_route_table.route_tb.id # Route table with internet gateway route

}

# EC2 Instance for web server
# Creates a virtual machine in the public subnet with nginx web server
resource "aws_instance" "web" {
  ami                         = nonsensitive(data.aws_ssm_parameter.aws_ami.value) # Use latest Amazon Linux 2 AMI
  instance_type               = var.instance                                       # Small instance type (1 vCPU, 1 GB RAM) - Free tier eligible
  vpc_security_group_ids      = [aws_security_group.sg_public.id]                  # Apply public security group for internet access
  subnet_id                   = aws_subnet.public_subnet.id                        # Deploy in the public subnet
  user_data_replace_on_change = true                                               # Force instance replacement when user_data changes

  # Bootstrap script to install and start nginx web server
  # Runs automatically when the instance first starts
  user_data = templatefile("./templates/startup_script.tpl", { environment = var.environment })

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-web-vm") })

}

