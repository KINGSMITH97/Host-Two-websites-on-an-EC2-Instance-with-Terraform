
output "pb_subnet" {
  value = aws_subnet.pb_subnet.id
}

output "gateway_id" {
  value = aws_internet_gateway.king_igw.id
}

output "route_table" {
  value = aws_route_table.pb_rtb.id
}

output "pb_sg" {
  value = aws_security_group.pb_sg.id
}

output "aws_network_interface" {
  value = aws_network_interface.proj_ip.id
}

output "eip_1" {
  value = aws_eip.eip_1.id
}

output "eip_2" {
  value = aws_eip.eip_2.id
}
