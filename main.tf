#creating the VPC
resource "aws_vpc" "king_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    "Name" = var.vpc_cidr_block
  }
}

#creating subnet
resource "aws_subnet" "pb_subnet" {
  cidr_block        = var.subnet_cidr_block
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
  instance = aws_instance.web_server.id
  associate_with_private_ip = "10.0.2.30"
  depends_on = [ aws_internet_gateway.king_igw ]

  tags = {
    Name = "eip_1"
  }
}

resource "aws_eip" "eip_2" {
  domain = "vpc"
  instance = aws_instance.web_server.id
  associate_with_private_ip = "10.0.2.31"
  depends_on = [ aws_internet_gateway.king_igw ]

  tags = {
    Name = "eip_2"
  }
}

#creating the ec2 instance
resource "aws_instance" "web_server" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = "keypair"

  network_interface {
    network_interface_id = aws_network_interface.proj_ip.id
    device_index         = 0
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/frigg/tfP/project3/keypair.pem")
  }

  provisioner "file" {
    source      = "/home/frigg/tfP/project3/web1"
    destination = "/home/ec2-user/web1/"
  }

  provisioner "file" {
    source      = "/home/frigg/tfP/project3/web2"
    destination = "/home/ec2-user/web2/"
  }

  provisioner "file" {
    source      = "/home/frigg/tfP/project3/httpd.conf.template"
    destination = "/home/ec2-user/httpd.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo cp -r /home/ec2-user/web1/ /var/www/html/web1/",
      "sudo cp -r /home/ec2-user/web2/ /var/www/html/web2/",
      "sudo chown -R $USER:$USER /var/www/html", # Change ownership to 'apache' for HTTPD
      "sudo chmod -R 755 /var/www/html",
      "sudo chmod 777 /etc/httpd/conf/httpd.conf",
      "sudo cat /home/ec2-user/httpd.conf >> /etc/httpd/conf/httpd.conf",
      "sudo systemctl restart httpd",
    ]
  }

  tags = {
    Name = "web_server"
  }
}
