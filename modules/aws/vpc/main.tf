#-----------------------------------------------------------------------------------------------------------------------
# VPC
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  # DNS settings
  enable_dns_hostnames = true
  enable_dns_support   = true

  instance_tenancy = "default"

  tags = merge(
    { Name = var.name }, var.tags
  )
}


#-----------------------------------------------------------------------------------------------------------------------
# Private Subnets
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_subnets[count.index]
  # Cycles through length(var.availability_zones) and starts from first element if count.index is out of range
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  # IPV6 settings
  assign_ipv6_address_on_creation                = false
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_native = false

  # Assign public IP for EC2 instance in creation or not
  map_public_ip_on_launch = false

  tags = merge(
    { "Name" = "${var.name}-private-subnet-${count.index}" }, var.tags
  )
}


#-----------------------------------------------------------------------------------------------------------------------
# Public Subnets
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnets[count.index]
  # Cycles through length(var.availability_zones) and starts from first element if count.index is out of range
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  # IPV6 settings
  assign_ipv6_address_on_creation                = false
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_native = false

  # Assign public IP for EC2 instance in creation or not
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name"                   = "${var.name}-public-subnet-${count.index}",
      "kubernetes.io/role/elb" = 1
    },
    var.tags
  )
}


#-----------------------------------------------------------------------------------------------------------------------
# IP NAT IGW
#-----------------------------------------------------------------------------------------------------------------------

# Public Elastic IP that faces internet
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = var.tags
}

# IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-igw" }, var.tags,
  )
}

# Nat Gateway
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  # We allways create NAT Gateway in the first available subnet
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat.id

  tags = merge(
    { "Name" = "${var.name}-nat-gw" }, var.tags,
  )

  depends_on = [aws_internet_gateway.this]
}


#-----------------------------------------------------------------------------------------------------------------------
# Routing
#-----------------------------------------------------------------------------------------------------------------------

# 0.0.0.0/0 -> private_nat_gateway
resource "aws_route" "private_nat_gateway" {
  count = length(var.private_subnets)

  nat_gateway_id = aws_nat_gateway.this[0].id
  destination_cidr_block = "0.0.0.0/0"
  # We will statically route all traffic through one nat in the first subnet
  route_table_id = aws_route_table.private[count.index].id
}

# 0.0.0.0/0 -> public_internet_gateway
resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets)

  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public[count.index].id
}

# Private RT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  count = length(var.private_subnets)

  tags = merge(
    { "Name" = "${var.name}-private-rt-${count.index}" }, var.tags,
  )
}

# Public RT
resource "aws_route_table" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-public-rt-${count.index}" }, var.tags,
  )
}

# private subnet -> private-rt
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# private subnet -> public-rt
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}



