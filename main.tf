

module "create_vpc" {
  source = "./modules/vpc"
  instance_id = module.create_ec2.instance_id
}

module "create_ec2" {
  source = "./modules/ec2_instance"
  network_interface_id = module.create_vpc.aws_network_interface
}

