output "vpc" {
  description = "VPC"
  value       = aws_vpc.create_vpc
}

output "vpc_id" {
  description = "VPC"
  value       = aws_vpc.create_vpc.id
}

output "ip_nat_allocation" {
  description = "Static IP nat allocation"
  value       = aws_eip.create_static_ip_nat_allocation
}

output "internet_gateway" {
  description = "Internet gateway"
  value       = aws_internet_gateway.create_internet_gateway
}

output "internet_gateway_id" {
  description = "Internet gateway"
  value       = aws_internet_gateway.create_internet_gateway.id
}

output "nat_gateway" {
  description = "Nat gateway"
  value       = aws_nat_gateway.create_nat_gateway
}

output "nat_gateway_id" {
  description = "Nat gateway"
  value       = aws_nat_gateway.create_nat_gateway.id
}

output "egress_only_internet_gateway" {
  description = "Egress only internet gateway"
  value       = aws_egress_only_internet_gateway.create_egress_only_internet_gateway
}

output "egress_only_internet_gateway_id" {
  description = "Egress only internet gateway"
  value       = aws_egress_only_internet_gateway.create_egress_only_internet_gateway[0].id
}

output "subnets" {
  description = "Subnets"
  value       = aws_subnet.create_subnets
}

output "subnets_ids" {
  description = "Subnets ID's"
  value = {
    public  = local.public_subnets_ids
    private = local.private_subnets_ids
  }
}

output "public_route_table" {
  description = "Public route table"
  value       = module.creat_public_route_table[0]
}

output "private_route_table" {
  description = "Private route table"
  value       = module.creat_private_route_table[0]
}
