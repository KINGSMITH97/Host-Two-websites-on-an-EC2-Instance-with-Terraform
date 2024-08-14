
module "create_vpc" {
  source = "./modules/vpc"
  subnet_cidr_block = var.subnet_cidr_block
  vpc_cidr_block = var.vpc_cidr_block
  instance_id = module.create_ec2.instance_id
}

module "create_ec2" {
  source = "./modules/ec2_instance"
  network_interface_id = module.create_vpc.aws_network_interface
}

