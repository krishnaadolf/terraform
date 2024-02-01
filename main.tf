provider "aws"{
    region = "us-east-2"
}
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
tags ={
    Name = "terraform-vpc"
}
}
resource "aws_subnet" "terra-sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
tags ={
  Name = "teera-public-sub1"
}
}

resource "aws_subnet" "terra-sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
tags ={
    Name = "terra-pre-sub1"
}
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
tags ={
    Name = "terraform_igw"
}
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id
tags ={
    Name = "terraform-RT"
}
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
}
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.terra-sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.terra-sub2.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_security_group" "terraSg" {
  name   = "sg_terra"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terra-sg"
  }
}
resource "aws_instance" "terraform"{
   ami  ="ami-05fb0b8c1424f266b"
   instance_type = "t2.micro"
   vpc_security_group_ids = [aws_security_group.terraSg.id]
   subnet_id = aws_subnet.terra-sub1.id
tags ={
    Name = "terraform-test"
}
}
resource "aws_instance" "terraform_2"{
   ami  ="ami-05fb0b8c1424f266b"
   instance_type = "t2.micro"
   vpc_security_group_ids = [aws_security_group.terraSg.id]
   subnet_id = aws_subnet.terra-sub2.id
tags ={
    Name = "terraform-test2"
}
}
resource "aws_network_interface" "terraform_2" {
  subnet_id       = aws_subnet.terra-sub2.id
  private_ips     = ["10.0.1.12"]
  security_groups = [aws_security_group.terraSg.id]

  attachment {
    instance     = aws_instance.terraform_2.id
    device_index = 1
  }
}
output "private_ip"{
    value = aws_instance.terraform_2.private_ip
}
