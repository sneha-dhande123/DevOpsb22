variable "instance_type" {
 type = list  
default = ["t2.micro","t2.small","t2.medium","t2.large","t2.xlarge"]
}         

variable "username" {
    type = number 
  default = 123
}

variable "eip" {
    type = bool
   default = false
}

