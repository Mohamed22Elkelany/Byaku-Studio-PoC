locals {
  module_name       = "tf-aws/vpc"
  module_version    = file("${path.module}/RELEASE")
  module_maintainer = "Cloud Softway"
  default_tags = {
    ModuleName       = local.module_name
    ModuleVersion    = local.module_version
    ModuleMaintainer = local.module_maintainer
  }

  public_subnet_azs  = distinct(var.public_subnets[*].availability_zone)
  private_subnet_azs = distinct(var.private_subnets[*].availability_zone)
  regional_nat       = var.nat_gateway_mode == "regional"
  nat_gateway_azs    = local.regional_nat ? [] : var.single_nat_gateway ? slice(local.public_subnet_azs, 0, 1) : local.public_subnet_azs
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(local.default_tags, var.tags, {
    Name = var.vpc_name
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-internet-gateway"
  })
}

###################################
## Public Subnets Configurations ##
###################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index].cidr
  availability_zone       = var.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = var.public_subnets[count.index].map_public_ip_on_launch

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-public-subnet-${var.public_subnets[count.index].availability_zone}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-public-route-table"
  })
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#########################################
##### Private Subnet Configurations #####
#########################################
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index].cidr
  availability_zone = var.private_subnets[count.index].availability_zone

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-private-${var.private_subnets[count.index].tier}-subnet-${var.private_subnets[count.index].availability_zone}"
    Tier = var.private_subnets[count.index].tier
  })
}

# One private route table per AZ so each AZ egresses through its own NAT
# gateway. With single_nat_gateway, every AZ routes through the first one; with a
# regional NAT gateway, every AZ routes through it.
resource "aws_route_table" "private" {
  for_each = toset(local.private_subnet_azs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = local.regional_nat ? aws_nat_gateway.regional[0].id : aws_nat_gateway.main[contains(local.nat_gateway_azs, each.key) ? each.key : local.nat_gateway_azs[0]].id
  }

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-private-route-table-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.private_subnets[count.index].availability_zone].id
}

######################################################
## NAT Gateway Resource with Elastic IP Association ##
######################################################
resource "aws_nat_gateway" "main" {
  for_each = toset(local.nat_gateway_azs)

  connectivity_type = "public"
  subnet_id         = aws_subnet.public[index(var.public_subnets[*].availability_zone, each.key)].id
  allocation_id     = aws_eip.nat_gateway[each.key].id

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-natgw-${each.key}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat_gateway" {
  for_each = toset(local.nat_gateway_azs)

  domain = "vpc"

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-natgw-eip-${each.key}"
  })
}

# Regional (multi-AZ) NAT gateway in manual mode: one Elastic IP per public-subnet
# AZ, so the egress IPs are fixed and known.
resource "aws_nat_gateway" "regional" {
  count = local.regional_nat ? 1 : 0

  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"
  connectivity_type = "public"

  dynamic "availability_zone_address" {
    for_each = toset(local.public_subnet_azs)
    content {
      availability_zone = availability_zone_address.value
      allocation_ids    = [aws_eip.regional_nat[availability_zone_address.value].id]
    }
  }

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-natgw-regional"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "regional_nat" {
  for_each = local.regional_nat ? toset(local.public_subnet_azs) : toset([])

  domain = "vpc"

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-natgw-regional-eip-${each.key}"
  })
}
