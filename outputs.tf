# Output the public DNS hostname of the EC2 instance
# This can be used to access the web server from the internet
output "instance_instance_public_dns" {
  description = "Public DNS hostname for EC2 instance"
  value       = "http://${aws_instance.web.public_dns}:${var.http_port}"


}

# Output the VPC ID for reference by other resources or modules
# Useful for networking configuration and troubleshooting
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id


}

# Output the public subnet ID for reference
# Can be used when launching additional resources in the same subnet
output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.public_subnet.id


}