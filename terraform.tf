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

  backend "s3" {
    bucket = "taco-wagon20251005154413569900000001"
    region = "us-east-1"
    
  }
}
