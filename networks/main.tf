resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = var.vpc-name
  }
}

resource "aws_internet_gateway" "igateway" { 
  vpc_id =  aws_vpc.myvpc.id 

  tags = {
    Name = var.igw-name
  }
}
resource "aws_subnet" "publicsubnet" {

  vpc_id = aws_vpc.myvpc.id 
  cidr_block       = var.subnet-cidr[count.index]
  count = length(var.subnet-cidr)
  availability_zone = var.zone[count.index]
  
  tags = {
    Name = var.subnet-name[count.index]
  }
}
resource "aws_subnet" "privatesubnet" {

  vpc_id = aws_vpc.myvpc.id 
  cidr_block       = var.subnetcidr-1[count.index]
  count = length(var.subnetcidr-1)
  availability_zone = var.zone-2[count.index]
  
  tags = {
    Name = var.subnetname1[count.index]
  }
}
resource "aws_eip" "elastic" {
  vpc      = true
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.publicsubnet[0].id
  tags = {
    Name = var.nat-name
  }
  depends_on = [aws_internet_gateway.igateway]
}
resource "aws_route_table" "table-public" {

  vpc_id = aws_vpc.myvpc.id 

  route {
    cidr_block = var.routepublic-cidr
    gateway_id = aws_internet_gateway.igateway.id
  }

  tags = {
    Name = var.routepublic
  }
}
resource "aws_route_table" "table-private" {
  vpc_id =  aws_vpc.myvpc.id

  route {
    cidr_block = var.routepublic-cidr
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = var.routeprivate
  }
}
resource "aws_route_table_association" "public-association-1" {  
  subnet_id = aws_subnet.publicsubnet[0].id
  route_table_id = aws_route_table.table-public.id
}

resource "aws_route_table_association" "public-association-2" {  
  subnet_id = aws_subnet.publicsubnet[1].id
  route_table_id = aws_route_table.table-public.id
}

resource "aws_route_table_association" "private-association-1" {  
  subnet_id = aws_subnet.privatesubnet[0].id
  route_table_id = aws_route_table.table-private.id
}

resource "aws_route_table_association" "private-association-2" {  
  subnet_id = aws_subnet.privatesubnet[1].id
  route_table_id = aws_route_table.table-private.id
}

resource "aws_security_group" "securitygroup" {
  name        = var.security-group-name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port        = 80 
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.routepublic-cidr]
  }
  ingress {
    from_port        = 22 
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.routepublic-cidr]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.routepublic-cidr]
  }

}