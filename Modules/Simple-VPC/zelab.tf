##----------------------------------------- VPC and Gateway
###
resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.23.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_internet_gateway" "ze-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "InternetGateway"
  }
}

##----------------------------------------- Subnets
#### Public Subnet 01
resource "aws_subnet" "pub-net01" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.1.0/24"

  tags = {
    Name = "PubSubnet01"
  }
}

#### Public Subnet 02
resource "aws_subnet" "pub-net02" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.2.0/24"

  tags = {
    Name = "PubSubnet02"
  }
}

#### Private Subnet 01
resource "aws_subnet" "priv-net01" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.3.0/24"

  tags = {
    Name = "PrivSubnet01"
  }
}

#### Private Subnet 02
resource "aws_subnet" "priv-net02" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.4.0/24"

  tags = {
    Name = "PrivSubnet02"
  }
}

##----------------------------------------- Route Tables
###
resource "aws_route_table" "ze-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ze-igw.id
  }

  tags = {
    Name = "PublicRoute"
  }
}

##----------------------------------------- Route Tables Association
#### Association to the Public Subnet 01
resource "aws_route_table_association" "to-pub01" {
  subnet_id      = aws_subnet.pub-net01.id
  route_table_id = aws_route_table.ze-route.id
}

#### Association to the Public Subnet 02
resource "aws_route_table_association" "to-pub02" {
  subnet_id      = aws_subnet.pub-net02.id
  route_table_id = aws_route_table.ze-route.id
}

##----------------------------------------- Security Groups
#### Allow HTTPS from Internet
resource "aws_security_group" "pubnet-tls" {
  name        = "HTTPS"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "TLS back to VPC"
    from_port        = 1024
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTPS Traffic"
  }
}

#### Allow traffic from Public
resource "aws_security_group" "privnet-sql" {
  name        = "MySQL"
  description = "Allow SQL inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "All from Public"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    security_groups  = [aws_security_group.pubnet-tls.id]
  }

  egress {
    description      = "All to Public"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    security_groups  = [aws_security_group.pubnet-tls.id]
  }

  tags = {
    Name = "SQL Traffic"
  }
}
