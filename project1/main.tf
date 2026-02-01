provider "aws" {

  region = var.aws_region

}



# 1. Create VPC

resource "aws_vpc" "proj1_vpc" {

  cidr_block           = "10.0.0.0/16"

  enable_dns_support   = true

  enable_dns_hostnames = true

  tags = { Name = "Project1-VPC" }

}



# 2. Create Public Subnet

resource "aws_subnet" "proj1_subnet" {

  vpc_id                  = aws_vpc.proj1_vpc.id

  cidr_block              = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = { Name = "Project1-Subnet" }

}



# 3. Internet Gateway

resource "aws_internet_gateway" "proj1_igw" {

  vpc_id = aws_vpc.proj1_vpc.id

  tags = { Name = "Project1-IGW" }

}



# 4. Route Table

resource "aws_route_table" "proj1_rt" {

  vpc_id = aws_vpc.proj1_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.proj1_igw.id

  }

  tags = { Name = "Project1-RT" }

}



resource "aws_route_table_association" "proj1_rta" {

  subnet_id      = aws_subnet.proj1_subnet.id

  route_table_id = aws_route_table.proj1_rt.id

}



# 5. Security Group

resource "aws_security_group" "proj1_sg" {

  name        = "project1-sg"

  description = "Allow HTTP and SSH"

  vpc_id      = aws_vpc.proj1_vpc.id



  ingress {

    description = "HTTP"

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

    cidr_blocks = ["0.0.0.0/0"] # Open to all for this lab

  }



  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}



# 6. Find Ubuntu AMI

data "aws_ami" "ubuntu" {

  most_recent = true

  owners      = ["099720109477"] # Canonical

  filter {

    name   = "name"

    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]

  }

}



# 7. Create EC2 Instance

resource "aws_instance" "web_server" {

  ami           = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id     = aws_subnet.proj1_subnet.id

  vpc_security_group_ids = [aws_security_group.proj1_sg.id]

  key_name = var.key_name

  user_data = file("user_data.sh")

  tags = { Name = "Project1-Server" }

}
