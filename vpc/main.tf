resource "aws_vpc" "a4l-vpc1" {
  cidr_block                       = "10.16.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "a4l-vpc1"
  }
}

resource "aws_subnet" "sn_A" {
  vpc_id                          = aws_vpc.a4l-vpc1.id
  for_each                        = var.subnets_A
  cidr_block                      = cidrsubnet(aws_vpc.a4l-vpc1.cidr_block, 4, each.value)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.a4l-vpc1.ipv6_cidr_block, 8, each.value)
  availability_zone               = "us-east-1a"
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch = each.key == "web" ? true : false
  tags = {
  Name = "subnet-${each.key}-A" }


}

resource "aws_subnet" "sn_B" {
  vpc_id                          = aws_vpc.a4l-vpc1.id
  for_each                        = var.subnets_B
  cidr_block                      = cidrsubnet(aws_vpc.a4l-vpc1.cidr_block, 4, each.value)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.a4l-vpc1.ipv6_cidr_block, 8, each.value)
  availability_zone               = "us-east-1b"
  map_public_ip_on_launch = each.key == "web" ? true : false
  assign_ipv6_address_on_creation = true
  tags = {
  Name = "subnet-${each.key}-B" }

}

resource "aws_subnet" "sn_C" {
  vpc_id                          = aws_vpc.a4l-vpc1.id
  for_each                        = var.subnets_C
  cidr_block                      = cidrsubnet(aws_vpc.a4l-vpc1.cidr_block, 4, each.value)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.a4l-vpc1.ipv6_cidr_block, 8, each.value)
  availability_zone               = "us-east-1c"
  map_public_ip_on_launch = each.key == "web" ? true : false
  assign_ipv6_address_on_creation = true
  tags = {
  Name = "subnet-${each.key}-C" }

}

resource "aws_internet_gateway" "a4l_igw" {
  vpc_id = aws_vpc.a4l-vpc1.id
  tags = {
    Name = "a4l-igw"
  }
  
}

resource "aws_route_table" "a4l_rt" {
    vpc_id = aws_vpc.a4l-vpc1.id
    tags = {
        Name = "a4l-rt"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.a4l_igw.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id      = aws_internet_gateway.a4l_igw.id
    }
  
}

resource "aws_route_table_association" "a4l_rt_association" {
    for_each = { A = aws_subnet.sn_A["web"] 
                 B = aws_subnet.sn_B["web"]
                 C = aws_subnet.sn_C["web"] }
    subnet_id      = each.value.id
    route_table_id = aws_route_table.a4l_rt.id 
}