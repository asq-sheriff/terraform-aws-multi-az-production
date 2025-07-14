# Root outputs.tf
# Pass through the most important outputs from the VPC module

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.vpc.nat_gateway_public_ip
}

# Useful for other modules/configurations
output "network_summary" {
  description = "Summary of the network configuration"
  value = {
    vpc_id              = module.vpc.vpc_id
    vpc_cidr            = module.vpc.vpc_cidr
    availability_zones  = module.vpc.availability_zones
    public_subnets      = module.vpc.public_subnet_ids
    private_subnets     = module.vpc.private_subnet_ids
    nat_gateway_ip      = module.vpc.nat_gateway_public_ip
    public_route_table  = module.vpc.public_route_table_id
    private_route_table = module.vpc.private_route_table_id
  }
}