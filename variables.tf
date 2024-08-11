variable "vpc_name" {
  type    = string
  default = "king_vpc"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.2.0/24"
}

variable "ami_id" {
  type    = string
  default = "ami-0ae8f15ae66fe8cda"
}