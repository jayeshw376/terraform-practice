# VPC
resource "aws_vpc" "Custom-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cust-vpc"
  }

}

# SUBNET
# public-subnet
resource "aws_subnet" "public-subnet" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.Custom-vpc.id
  availability_zone = "ap-northeast-3a"
  tags = {
    Name = "public-subnet"
  }
}

# private-subnet
resource "aws_subnet" "private-subnet" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.Custom-vpc.id
  availability_zone = "ap-northeast-3a"
  tags = {
    Name = "private-subnet"
  }

}


# INTERNET GATEWAY
resource "aws_internet_gateway" "Custom-ig" {
  vpc_id = aws_vpc.Custom-vpc.id
  tags = {
    Name = "cust-ig"
  }

}
# ROUTE TABLE
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.Custom-vpc.id
  tags = {
    Name = "public-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Custom-ig.id
  }
}

# ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# SECURITY GROUP
resource "aws_security_group" "Custom-sg" {
  vpc_id = aws_vpc.Custom-vpc.id
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "cust-sg"
  }

}


# ELASTIC-IP
resource "aws_eip" "Custom-eip" {
  vpc = true
}

# Nat-Gateway
resource "aws_nat_gateway" "Custom-ng" {
  allocation_id = aws_eip.Custom-eip.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "cust-ng"
  }

}

# Private-Rout table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.Custom-vpc.id
  tags = {
    Name = "cust-priv-rt"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Custom-ng.id
  }
}

# Subnet association for private route 
resource "aws_route_table_association" "private-rt-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

# EC2 -Instance

resource "aws_instance" "Custom_ec2" {
  ami             = "ami-07b2fe5d6ba52171e"
  instance_type   = "t2.micro"
  key_name        = "strike7620"
  subnet_id       = aws_subnet.private-subnet.id
  vpc_security_group_ids = [ aws_security_group.Custom-sg.id ]
#   security_groups = [aws_security_group.Custom-sg.id]?\
  tags = {
    Name = "cust-ec2"
  }
}
