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



resource "aws_nat_gateway" "a4l_natgw" {
    for_each = { A = aws_subnet.sn_A["web"] 
                 B = aws_subnet.sn_B["web"]
                 C = aws_subnet.sn_C["web"] }
    subnet_id      = each.value.id 
    allocation_id = aws_eip.a4l_eip[each.key].id
    
    tags = {
        Name = "a4l-natgw"
    }
    depends_on = [ aws_internet_gateway.a4l_igw ]
}

resource "aws_eip" "a4l_eip" {
    for_each = toset(["A", "B", "C"])
    tags = {
        Name = "a4l-eip${each.value}"
    }
    depends_on = [ aws_internet_gateway.a4l_igw ]
}

resource "aws_security_group" "a4l_sg" {
    name        = "a4l-sg"
    description = "Security group for a4l VPC"
    vpc_id      = aws_vpc.a4l-vpc1.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  
}
}

resource "aws_route_table" "a4l_private_rt" {
    vpc_id = aws_vpc.a4l-vpc1.id
    for_each = {
      A = aws_nat_gateway.a4l_natgw["A"].id
      B = aws_nat_gateway.a4l_natgw["B"].id
      C = aws_nat_gateway.a4l_natgw["C"].id
    }
    tags = {
        Name = "a4l-private-rt-${each.key}"
    }
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = each.value

    }
  
}

resource "aws_route_table_association" "a4l_private_rt_association_app" {
    for_each = { A = aws_subnet.sn_A["app"] 
                 B = aws_subnet.sn_B["app"]
                 C = aws_subnet.sn_C["app"] }
    subnet_id      = each.value.id
    route_table_id = aws_route_table.a4l_private_rt[each.key].id
  
}

resource "aws_route_table_association" "a4l_private_rt_association_db" {
    for_each = { A = aws_subnet.sn_A["db"] 
                 B = aws_subnet.sn_B["db"]
                 C = aws_subnet.sn_C["db"] }
    subnet_id      = each.value.id
    route_table_id = aws_route_table.a4l_private_rt[each.key].id
  
}

resource "aws_route_table_association" "a4l_private_rt_association_reserved" {
    for_each = { A = aws_subnet.sn_A["reserved"] 
                 B = aws_subnet.sn_B["reserved"]
                 C = aws_subnet.sn_C["reserved"] }
    subnet_id      = each.value.id
    route_table_id = aws_route_table.a4l_private_rt[each.key].id
  
}

resource "aws_ec2_instance_connect_endpoint" "a4l_ec2_ice" {
    ip_address_type = "ipv4"
    subnet_id = aws_subnet.sn_A["app"].id
    security_group_ids = [ aws_security_group.a4l_sg.id ]
    tags = {
        Name = "a4l-ec2-ice"
    }
  
}

resource "aws_instance" "demo" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.sn_A["app"].id
    vpc_security_group_ids = [ aws_security_group.a4l_sg.id ]
    tags = {
        name = "demo"
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
    filter {
        name = "architecture"
        values = ["x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
