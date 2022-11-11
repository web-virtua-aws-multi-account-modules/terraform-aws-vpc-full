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
locals {
  subnets = [for sb in var.subnets : {
    cidr_block              = sb.cidr_block
    availability_zone       = sb.availability_zone
    type                    = try(sb.is_private, false) ? "public" : "private"
    map_public_ip_on_launch = try(sb.map_public_ip_on_launch, true)
    tags                    = try(sb.tags, {})
  }]

  public_subnets_ids  = [for sb in aws_subnet.create_subnets : sb.id if split("-", sb.tags.tf-subnet)[3] == "public"]
  private_subnets_ids = [for sb in aws_subnet.create_subnets : sb.id if split("-", sb.tags.tf-subnet)[3] == "private"]
  public_subnet_nat  = try(local.public_subnets_ids[0], null)
}

resource "aws_subnet" "create_subnets" {
  count                   = length(local.subnets)
  vpc_id                  = aws_vpc.create_vpc.id
  cidr_block              = local.subnets[count.index].cidr_block
  map_public_ip_on_launch = local.subnets[count.index].map_public_ip_on_launch
  availability_zone       = local.subnets[count.index].availability_zone

  tags = merge(var.tags_ngtw, {
    Name        = "${var.vpc_name}-${local.subnets[count.index].type}-subnet-${substr(local.subnets[count.index].availability_zone, length(local.subnets[count.index].availability_zone) - 1, 1)}"
    "tf-subnet" = "${var.vpc_name}-${local.subnets[count.index].type}-subnet-${substr(local.subnets[count.index].availability_zone, length(local.subnets[count.index].availability_zone) - 1, 1)}"
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
  subnet_id     = local.public_subnet_nat

  tags = merge(var.tags_ngtw, {
    Name             = "${var.vpc_name}-ngtw"
    "tf-nat_gateway" = "${var.vpc_name}-ngtw"
  })

  depends_on = [
    aws_vpc.create_vpc,
    aws_subnet.create_subnets
  ]
}

# ----------------------------------------------------------------#
# Route table association
# ----------------------------------------------------------------#
module "creat_public_route_table" {
  count                          = length(local.public_subnets_ids) > 0 ? 1 : 0
  source                         = "web-virtua-aws-multi-account-modules/route-table/aws"
  name                           = "${var.vpc_name}-public-rtb"
  vpc_id                         = aws_vpc.create_vpc.id
  subnet_ids                     = local.public_subnets_ids
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

module "creat_private_route_table" {
  count                          = length(local.private_subnets_ids) > 0 ? 1 : 0
  source                         = "web-virtua-aws-multi-account-modules/route-table/aws"
  name                           = "${var.vpc_name}-private-rtb"
  vpc_id                         = aws_vpc.create_vpc.id
  subnet_ids                     = local.private_subnets_ids
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
