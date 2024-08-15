
variable "instance_id" {
  type = string
}

#creating the VPC
resource "aws_vpc" "king_vpc" {
  cidr_block       = data.aws_ssm_parameter.vpc_cidr_block.value
  instance_tenancy = "default"

  tags = {
    "Name" = "king_vpc"
  }
}

#creating subnet
resource "aws_subnet" "pb_subnet" {
  cidr_block        = data.aws_ssm_parameter.subnet_cidr_block.value
  vpc_id            = aws_vpc.king_vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "pb_subnet"
  }
}

#creating an internet gateway
resource "aws_internet_gateway" "king_igw" {
  vpc_id = aws_vpc.king_vpc.id

  tags = {
    "Name" = "king_igw"
  }
}

#creating a route table
resource "aws_route_table" "pb_rtb" {
  vpc_id = aws_vpc.king_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.king_igw.id
  }

  tags = {
    "Name" = "pb_rtb"
  }

}

resource "aws_route_table_association" "rtb_asc" {
  subnet_id      = aws_subnet.pb_subnet.id
  route_table_id = aws_route_table.pb_rtb.id
}

resource "aws_security_group" "pb_sg" {
  name        = "pb_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.king_vpc.id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pb_sg"
  }
}

resource "aws_network_interface" "proj_ip" {
  subnet_id = aws_subnet.pb_subnet.id
  security_groups = [aws_security_group.pb_sg.id]
  private_ips = [ "10.0.2.30","10.0.2.31" ]
}

resource "aws_eip" "eip_1" {
  domain = "vpc"
  instance = var.instance_id
  associate_with_private_ip = "10.0.2.30"
  depends_on = [ aws_internet_gateway.king_igw ]

  tags = {
    Name = "eip_1"
  }
}

resource "aws_eip" "eip_2" {
  domain = "vpc"
  instance = var.instance_id
  associate_with_private_ip = "10.0.2.31"
  depends_on = [ aws_internet_gateway.king_igw ]

  tags = {
    Name = "eip_2"
  }
}
