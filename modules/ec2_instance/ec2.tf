
variable "network_interface_id" {
  type = string
}

#creating the ec2 instance
resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = "keypair"

  network_interface {
    network_interface_id = var.network_interface_id
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
