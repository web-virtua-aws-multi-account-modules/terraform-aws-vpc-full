
variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "cidr_block" {
  description = "Cidr Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS Hostnames"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS Support"
  type        = bool
  default     = true
}

variable "enable_network_address_usage_metrics" {
  description = "Enable network address usage metrics"
  type        = bool
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Assign generated ipv6 cidr block"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to VPC"
  type        = map(any)
  default     = {}
}

variable "tags_eip" {
  description = "Tags to elastic IP nat allocation"
  type        = map(any)
  default     = {}
}

variable "tags_igtw" {
  description = "Tags to Internet Gateway"
  type        = map(any)
  default     = {}
}

variable "tags_ngtw" {
  description = "Tags to Nat Gateway"
  type        = map(any)
  default     = {}
}

variable "tags_rtb" {
  description = "Tags to route table"
  type        = map(any)
  default     = {}
}

variable "ou_name" {
  description = "Organization unit name"
  type        = string
  default     = "no"
}

variable "cidr_block_route_table" {
  description = "Cidr Block IPV4 route table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr_block_public_route_table" {
  description = "Cidr Block IPV4 public route table"
  type        = string
  default     = null
}

variable "cidr_block_private_route_table" {
  description = "Cidr Block IPV4 private route table"
  type        = string
  default     = null
}

variable "cidr_block_ipv6_route_table" {
  description = "Cidr Block IPV6 route table"
  type        = string
  default     = "::/0"
}

variable "cidr_block_ipv6_public_route_table" {
  description = "Cidr Block IPV6 public route table"
  type        = string
  default     = null
}

variable "cidr_block_ipv6_private_route_table" {
  description = "Cidr Block IPV6 private route table"
  type        = string
  default     = null
}

variable "public_subnets" {
  description = "Define the public subnets configuration"
  type = list(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool)
    tags                    = optional(map(any))
  }))
  default = []
}

variable "private_subnets" {
  description = "Define the private subnets configuration"
  type = list(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool)
    tags                    = optional(map(any))
  }))
  default = []
}

variable "custom_public_routes" {
  description = "List with customized routes to configure in public route table"
  type = list(object({
    cidr_block                 = string
    ipv6_cidr_block            = optional(string)
    destination_prefix_list_id = optional(string)
    carrier_gateway_id         = optional(string)
    core_network_arn           = optional(string)
    egress_only_gateway_id     = optional(string)
    gateway_id                 = optional(string)
    local_gateway_id           = optional(string)
    nat_gateway_id             = optional(string)
    network_interface_id       = optional(string)
    transit_gateway_id         = optional(string)
    vpc_endpoint_id            = optional(string)
    vpc_peering_connection_id  = optional(string)
  }))
  default = []
}

variable "custom_private_routes" {
  description = "List with customized routes to configure in private route table"
  type = list(object({
    cidr_block                 = string
    ipv6_cidr_block            = optional(string)
    destination_prefix_list_id = optional(string)
    carrier_gateway_id         = optional(string)
    core_network_arn           = optional(string)
    egress_only_gateway_id     = optional(string)
    gateway_id                 = optional(string)
    local_gateway_id           = optional(string)
    nat_gateway_id             = optional(string)
    network_interface_id       = optional(string)
    transit_gateway_id         = optional(string)
    vpc_endpoint_id            = optional(string)
    vpc_peering_connection_id  = optional(string)
  }))
  default = []
}
