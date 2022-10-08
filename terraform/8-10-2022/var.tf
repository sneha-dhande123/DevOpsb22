variable "region" {
  type = string #required
}
variable "profile" {
  type = string #required 
}

variable "cidr_block" {
  type = string #required
}
# variable "tags" {
#   type = any
#     default = "customvpc"
# }
# variable "env" {
#   type = any
#   default= ""
# }
# variable "projectname" {
#   type = any
#   default= ""
# }

variable "public_cidr_block" {
  type = list(any) #required
}

variable "private_cidr_block" {
  type = list(any) #required
}
# variable "instance_type" {
#   type = string #required
# }
# variable "key_name" {
#   type = string #required
# }


# output "public_ip_address" {
#   value = aws_instance.this.public_ip
# }
