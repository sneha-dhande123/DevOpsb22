resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "publicsubnet" {
  count      = length(var.public_cidr_block)
  vpc_id     = aws_vpc.this.id
  cidr_block = element(var.public_cidr_block, count.index)
}

resource "aws_subnet" "privatesubent" {
  count      = length(var.private_cidr_block)
  vpc_id     = aws_vpc.this.id
  cidr_block = element(var.private_cidr_block, count.index)
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "a" {
  count          = length(var.public_cidr_block)
  subnet_id      = element(var.public_cidr_block, count.index)
  route_table_id = aws_route_table.rt.id
}


resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }
}
resource "aws_route_table_association" "ab" {
  count          = length(var.private_cidr_block)
  subnet_id      = element(var.private_cidr_block, count.index)
  route_table_id = aws_route_table.rt.id
}


resource "aws_eip" "lb" {
  vpc = true
}
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.publicsubnet[1].id
  depends_on    = [aws_internet_gateway.igw]
}
