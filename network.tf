resource "aws_vpc" "volleyball_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "volleyball-vpc"
  }
}

resource "aws_subnet" "application_subnets" {
  count = 2
  vpc_id            = aws_vpc.volleyball_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.volleyball_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "application-subnet-${count.index}"
  }
}

resource "aws_subnet" "database_subnets" {
  count = 2
  vpc_id            = aws_vpc.volleyball_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.volleyball_vpc.cidr_block, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "database-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "volleyball_igw" {
  vpc_id = aws_vpc.volleyball_vpc.id

  tags = {
    Name = "volleyball-igw"
  }
}

resource "aws_route_table" "volleyball_public_rt" {
  vpc_id = aws_vpc.volleyball_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.volleyball_igw.id
  }

  tags = {
    Name = "volleyball-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.application_subnets[count.index].id
  route_table_id = aws_route_table.volleyball_public_rt.id
}