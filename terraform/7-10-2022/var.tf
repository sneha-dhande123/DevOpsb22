variable "region" {
  type = string
}
variable "profile" {
  type = string
}

variable "cidr_block" {
  type = string
}
variable "tags" {
  type = string
}

variable "public_cidr_block" {
  type = string
}

variable "private_cidr_block" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}


output "public_ip_address" {
  value = aws_instance.this.public_ip
}
