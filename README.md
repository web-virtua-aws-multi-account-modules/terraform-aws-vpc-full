# AWS VPC for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of a complete VPC network across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of VPC network configurations for this module:

- VPC IPV4 and or IPV6
- Egress only internet gateway
- Internet gateway
- NAT gateway
- Subnets
- Route tables

## Usage exemples


### VPC network with IPV4 and IPV6

```hcl
module "vpc_main" {
  source      = "web-virtua-aws-multi-account-modules/vpc-full/aws"
  vpc_name = "tf-vpc-test"
  cidr_block    = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  subnets = var.subnets

  providers = {
    aws = aws.network_dev
  }
}
```

### VPC network only IPV4

```hcl
module "vpc_main" {
  source      = "web-virtua-aws-multi-account-modules/vpc-full/aws"
  vpc_name = "tf-vpc-test"
  cidr_block    = "10.0.0.0/16"
  subnets = var.subnets

  providers = {
    aws = aws.network_dev
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| vpc_name | `string` | `-` | yes | Name to VPC and dependent resources | `-` |
| cidr_block | `string` | `10.0.0.0/16` | no | VPC Cidr Block | `-` |
| enable_dns_hostnames | `bool` | `true` | no | Enable DNS Hostnames | `*`false <br> `*`true |
| enable_dns_support | `bool` | `true` | no | Enable DNS Support | `*`false <br> `*`true |
| enable_network_address_usage_metrics | `bool` | `false` | no | Enable network address usage metrics | `*`false <br> `*`true |
| assign_generated_ipv6_cidr_block | `bool` | `false` | no | Assign generated ipv6 cidr block | `*`false <br> `*`true |
| cidr_block_route_table | `string` | `0.0.0.0/0` | no | Cidr Block IPV4 route table | `-` |
| cidr_block_ipv6_route_table | `string` | `::/0` | no | Cidr Block IPV6 route table | `-` |
| subnets | `list` | `[]` | no | Define subnets configuration | `-` |
| ou_name | `string` | `no` | no | Organization unit name | `-` |
| tags | `map(any)` | `{}` | no | Tags to resources | `-` |
| tags_eip | `map(any)` | `{}` | no | Tags to elastic IP | `-` |
| tags_igtw | `map(any)` | `{}` | no | Tags to internet gateway | `-` |
| tags_ngtw | `map(any)` | `{}` | no | Tags to NAT gateway | `-` |
| tags_rtb | `map(any)` | `{}` | no | Tags to NAT gateway | `-` |

* Model of variable subnets
```hcl
variable "subnets" {
  description = "Define the subnets configuration"
  type = list(object({
    cidr_block              = string
    availability_zone       = string
    is_private              = optional(bool)
    map_public_ip_on_launch = optional(bool)
    tags                    = optional(map(any))
  }))
  default = [
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      is_private              = false
      map_public_ip_on_launch = true
      tags                    = {}
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-east-1b"
      is_private              = true
      map_public_ip_on_launch = true
    },
  ]
}
```

## Resources

| Name | Type |
|------|------|
| [aws_vpc.create_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_egress_only_internet_gateway.create_egress_only_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) | resource |
| [aws_eip.create_static_ip_nat_allocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.create_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.create_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_subnet.create_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_route_table.create_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.create_associate_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `vpc` | All informations of the VPC |
| `vpc_id` | VPC ID |
| `ip_nat_allocation` | All informations of the IP nat allocation |
| `internet_gateway` | All informations of the internet gateway |
| `internet_gateway_id` | Internet gateway ID |
| `nat_gateway` | All informations of the NAT gateway |
| `nat_gateway_id` | NAT gateway ID |
| `egress_only_internet_gateway` | All informations of the egress only internet gateway |
| `egress_only_internet_gateway_id` | Egress only internet gateway ID |
| `subnets` | All informations of the Subnets |
| `subnets_ids` | Object with public and private subnets IDs |
| `public_route_table` | All informations of the public route table |
| `private_route_table` | All informations of the private route table |
