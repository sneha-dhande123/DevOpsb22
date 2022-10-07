terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = var.region
  profile = var.profile
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.tags
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.tags}-igw"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.public_cidr_block

  tags = {
    Name = "${var.tags}-publicsubnet"
  }
}

resource "aws_subnet" "privatesubent" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_cidr_block

  tags = {
    Name = "${var.tags}-privatesubnet"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_eip" "lb" {
  vpc = true
}
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.publicsubnet.id

  tags = {
    Name = "${var.tags}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }
}
resource "aws_route_table_association" "ab" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.rt.id
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "allow_tls" {
  name        = "${var.tags}-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
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

  tags = {
    Name = "${var.tags}-SG"
  }
}


resource "tls_private_key" "key-tf" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.key-tf.public_key_openssh

}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.publicsubnet.id
  user_data                   = <<EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install nginx -y
  sudo systemctl start nginx
  sudo systemctl enable nginx
EOF
  tags = {
    Name = "${var.tags}-instance"
  }
}
