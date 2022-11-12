# ----------------------------------------------------------------#
# VPC
# ----------------------------------------------------------------#
resource "aws_vpc" "create_vpc" {
  cidr_block                           = var.cidr_block
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge(var.tags, {
    Name      = var.vpc_name
    "tf-type" = "vpc"
    "tf-vpc"  = var.vpc_name
    "tf-ou"   = var.ou_name
  })
}

resource "aws_egress_only_internet_gateway" "create_egress_only_internet_gateway" {
  count  = var.assign_generated_ipv6_cidr_block ? 1 : 0
  vpc_id = aws_vpc.create_vpc.id
}

# ----------------------------------------------------------------#
# Subnets
# ----------------------------------------------------------------#
resource "aws_subnet" "create_public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.create_vpc.id
  cidr_block              = var.public_subnets[count.index].cidr_block
  map_public_ip_on_launch = var.public_subnets[count.index].map_public_ip_on_launch
  availability_zone       = var.public_subnets[count.index].availability_zone

  tags = merge(var.tags_ngtw, {
    Name        = "${var.vpc_name}-public-subnet-${substr(var.public_subnets[count.index].availability_zone, length(var.public_subnets[count.index].availability_zone) - 1, 1)}"
    "tf-subnet" = "${var.vpc_name}-public-subnet-${substr(var.public_subnets[count.index].availability_zone, length(var.public_subnets[count.index].availability_zone) - 1, 1)}"
  })
}

resource "aws_subnet" "create_private_subnets" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.create_vpc.id
  cidr_block              = var.private_subnets[count.index].cidr_block
  map_public_ip_on_launch = var.private_subnets[count.index].map_public_ip_on_launch
  availability_zone       = var.private_subnets[count.index].availability_zone

  tags = merge(var.tags_ngtw, {
    Name        = "${var.vpc_name}-private-subnet-${substr(var.private_subnets[count.index].availability_zone, length(var.private_subnets[count.index].availability_zone) - 1, 1)}"
    "tf-subnet" = "${var.vpc_name}-private-subnet-${substr(var.private_subnets[count.index].availability_zone, length(var.private_subnets[count.index].availability_zone) - 1, 1)}"
  })
}

# ----------------------------------------------------------------#
# Gateways
# ----------------------------------------------------------------#
resource "aws_eip" "create_static_ip_nat_allocation" {
  vpc = true

  tags = merge(var.tags_eip, {
    Name    = "${var.vpc_name}-ip-nat-allocation"
    "tf-ip" = "${var.vpc_name}-ip-nat-allocation"
  })
}

resource "aws_internet_gateway" "create_internet_gateway" {
  vpc_id = aws_vpc.create_vpc.id

  tags = merge(var.tags_igtw, {
    Name                  = "${var.vpc_name}-igtw"
    "tf-internet-gateway" = "${var.vpc_name}-igtw"
  })

  depends_on = [
    aws_vpc.create_vpc
  ]
}

resource "aws_nat_gateway" "create_nat_gateway" {
  allocation_id = aws_eip.create_static_ip_nat_allocation.id
  subnet_id     = aws_subnet.create_public_subnets[0].id

  tags = merge(var.tags_ngtw, {
    Name             = "${var.vpc_name}-ngtw"
    "tf-nat-gateway" = "${var.vpc_name}-ngtw"
  })

  depends_on = [
    aws_vpc.create_vpc,
    aws_subnet.create_public_subnets
  ]
}

# ----------------------------------------------------------------#
# Route table association
# ----------------------------------------------------------------#
module "create_public_route_table" {
  count                          = length(aws_subnet.create_public_subnets) > 0 ? 1 : 0
  source                         = "web-virtua-aws-multi-account-modules/route-table/aws"
  name                           = "${var.vpc_name}-public-rtb"
  vpc_id                         = aws_vpc.create_vpc.id
  subnet_ids                     = [for sb in aws_subnet.create_public_subnets : sb.id]
  gateway_id                     = aws_internet_gateway.create_internet_gateway.id
  egress_only_internet_gatewa_id = try(aws_egress_only_internet_gateway.create_egress_only_internet_gateway[0].id, null)
  ou_name                        = var.ou_name
  tags                           = var.tags_rtb
  cidr_block_route_table         = var.cidr_block_route_table
  cidr_block_ipv6_route_table    = var.cidr_block_ipv6_route_table

  depends_on = [
    aws_internet_gateway.create_internet_gateway
  ]
}

module "create_private_route_table" {
  count                          = length(aws_subnet.create_private_subnets) > 0 ? 1 : 0
  source                         = "web-virtua-aws-multi-account-modules/route-table/aws"
  name                           = "${var.vpc_name}-private-rtb"
  vpc_id                         = aws_vpc.create_vpc.id
  subnet_ids                     = [for sb in aws_subnet.create_private_subnets : sb.id]
  gateway_id                     = aws_nat_gateway.create_nat_gateway.id
  egress_only_internet_gatewa_id = try(aws_egress_only_internet_gateway.create_egress_only_internet_gateway[0].id, null)
  ou_name                        = var.ou_name
  tags                           = var.tags_rtb
  cidr_block_route_table         = var.cidr_block_route_table
  cidr_block_ipv6_route_table    = var.cidr_block_ipv6_route_table

  depends_on = [
    aws_nat_gateway.create_nat_gateway
  ]
}
