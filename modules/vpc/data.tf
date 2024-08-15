data "aws_ssm_parameter" "vpc_cidr_block" {
  name = "/project5/vpc_cidr"
}

data "aws_ssm_parameter" "subnet_cidr_block" {
  name = "/project5/subnet_cidr"
}