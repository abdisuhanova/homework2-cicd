provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "az_final_project" {}

resource "aws_vpc" "vpc_final_project" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
   Name = "${var.env}-vpc",
   "kubernetes.io/cluster/${var.env}-cluster" = "shared"
  }

}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.vpc_final_project.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.az_final_project.names[count.index]
  tags = {
    Name = "${var.env}-public_subnet-${count.index +1}"
     "kubernetes.io/cluster/${var.env}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }
   map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw_final_project" {
  vpc_id = aws_vpc.vpc_final_project.id

  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_final_project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_final_project.id
  }
   tags = {
    Name = "${var.env}-rt_public"
  }
}
resource "aws_route_table_association" "public_routes" {
 count = length(aws_subnet.public_subnet[*].id)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index) 
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.vpc_final_project.id
  cidr_block = var.private_subnet_cidrs [count.index]
  availability_zone = data.aws_availability_zones.az_final_project.names [count.index]
  tags = {
    Name = "${var.env}-private_subnet-${count.index +1}"
    "kubernetes.io/cluster/${var.env}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"              = 1

  }
}
 resource "aws_route_table" "rt_private" {
 count = length(var.private_subnet_cidrs) 
   vpc_id = aws_vpc.vpc_final_project.id
     route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.natgw[count.index].id
   }
    tags = {
    Name = "${var.env}-rt_private-${count.index +1}"
   }
 }
  resource "aws_nat_gateway" "natgw" {
   count = length(var.private_subnet_cidrs)
   allocation_id = aws_eip.eipnatgw[count.index].id
   subnet_id     = element(aws_subnet.private_subnet[*].id, count.index)
   tags = {
     Name = "${var.env}-eipnatgw-${count.index + 1}"
     }
 }
  resource "aws_eip" "eipnatgw" {
   count = length(var.private_subnet_cidrs)
   vpc      = true
   tags = {
     Name = "${var.env}-eipnatgw-${count.index + 1}"

   }
 }
  resource "aws_route_table_association" "private_routes" {
  count = length(aws_subnet.private_subnet[*].id)
   subnet_id      = element(aws_subnet.private_subnet[*].id, count.index) 
   route_table_id = aws_route_table.rt_private[count.index].id
 }

resource "aws_security_group" "public_sg" {
  name   =  "${var.env}-Public-sg"
  vpc_id = aws_vpc.vpc_final_project.id

  tags = {
    Name = "${var.env}-Public-sg"
  }
}
