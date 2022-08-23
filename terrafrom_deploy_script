terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
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

resource "aws_instance" "deploy_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this1.key_name
  iam_instance_profile   = aws_iam_instance_profile.test_profile_deploy.name
  vpc_security_group_ids = [aws_security_group.this1.id]
  user_data              = local.user_data


  tags = {
    Name = "deployment-instance"
  }

}

resource "aws_iam_role" "test_role_deploy" {
  name = "test_role_deploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}
resource "aws_iam_instance_profile" "test_profile_deploy" {
  name = "test_profile_deploy"
  role = aws_iam_role.test_role_deploy.name
}

resource "aws_iam_role_policy" "test_policy_deploy" {
  name = "test_policy_deploy"
  role = aws_iam_role.test_role_deploy.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "tls_private_key" "this1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "this1" {
  key_name   = "terraform-key-deployment"
  public_key = tls_private_key.this1.public_key_openssh

}
resource "aws_security_group" "this1" {
  name        = "allow_tls_deploy"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
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
    Name = "Deploy_SG"
  }
}

locals {
  user_data = <<EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install default-jdk -y 
  sudo apt install awscli -y 
  curl -O https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.82/bin/apache-tomcat-8.5.82.tar.gz
  sudo tar -xvf apache-tomcat-8.5.82.tar.gz -C /opt/ && sudo chmod 777 /opt/apache-tomcat-8.5.82/*  && sudo chown ubuntu: /opt/apache-tomcat-8.5.82/*
  sudo sh /opt/apache-tomcat-8.5.82/bin/shutdown.sh 
  aws s3 cp s3://test-artifact-pritam/student-11.war .
  sudo cp -rv student-11.war studentapp.war
  sudo cp -rv studentapp.war /opt/apache-tomcat-8.5.82/webapps/
  cd /opt/apache-tomcat-8.5.82/
  sudo ./bin/catalina.sh start 
EOF
}
