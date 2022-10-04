resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type[0]
}
resource "aws_instance" "wb" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type[1]
  }
resource "aws_instance" "w" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type[3]
  }
resource "aws_instance" "b" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type[2]
  }
resource "aws_instance" "a" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type[0]
  }
resource "aws_instance" "c" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type[4]
  }
resource "aws_instance" "e" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type[4]
  }



resource "aws_iam_user" "lb" {
  name = var.username
}

resource "aws_eip" "lb" {
  instance = aws_instance.web.id
  vpc      = var.eip
}
