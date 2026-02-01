terraform {

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 5.0"

    }

  }

}



provider "aws" {

  region = "eu-west-1"

}



# 1. NETWORKING: Get Default VPC & Subnets

data "aws_vpc" "default" {

  default = true

}



data "aws_subnets" "default" {

  filter {

    name   = "vpc-id"

    values = [data.aws_vpc.default.id]

  }

}



data "aws_ami" "amazon_linux_2" {

  most_recent = true

  owners      = ["amazon"]

  filter {

    name   = "name"

    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]

  }

}



# 2. SECURITY GROUPS

resource "aws_security_group" "alb_sg" {

  name        = "project-20-alb-sg"

  vpc_id      = data.aws_vpc.default.id



  ingress {

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}



resource "aws_security_group" "ec2_sg" {

  name        = "project-20-ec2-sg"

  vpc_id      = data.aws_vpc.default.id



  ingress {

    from_port       = 80

    to_port         = 80

    protocol        = "tcp"

    security_groups = [aws_security_group.alb_sg.id] # Only allow traffic from ALB

  }



  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}



# 3. LOAD BALANCER (ALB)

resource "aws_lb" "project_alb" {

  name               = "project-20-alb-yourname" # <--- Make this Unique!

  internal           = false

  load_balancer_type = "application"

  security_groups    = [aws_security_group.alb_sg.id]

  subnets            = data.aws_subnets.default.ids

}



resource "aws_lb_target_group" "app_tg" {

  name     = "project-20-tg"

  port     = 80

  protocol = "HTTP"

  vpc_id   = data.aws_vpc.default.id



  health_check {

    path                = "/"

    interval            = 10

    timeout             = 5

    healthy_threshold   = 2

    unhealthy_threshold = 2

    matcher             = "200"

  }

}



resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.project_alb.arn

  port              = "80"

  protocol          = "HTTP"



  default_action {

    type             = "forward"

    target_group_arn = aws_lb_target_group.app_tg.arn

  }

}



# 4. INSTANCES (The Servers)

resource "aws_instance" "web_server" {

  count                  = 2

  ami                    = data.aws_ami.amazon_linux_2.id

  instance_type          = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  subnet_id              = data.aws_subnets.default.ids[count.index]



  # Encryption is often required in labs

  root_block_device {

    encrypted = true 

    volume_type = "gp3"

  }



  user_data = <<-EOF

              #!/bin/bash

              yum update -y

              yum install -y httpd

              systemctl start httpd

              systemctl enable httpd

              # This line prints the specific server ID so you can see the switching

              echo "<h1>Project 20: Served by $(hostname -f)</h1>" > /var/www/html/index.html

              EOF



  tags = {

    Name = "Project20-Server-${count.index + 1}"

  }

}



resource "aws_lb_target_group_attachment" "tg_attachment" {

  count            = 2

  target_group_arn = aws_lb_target_group.app_tg.arn

  target_id        = aws_instance.web_server[count.index].id

  port             = 80

}



output "alb_dns_link" {

  value = "http://${aws_lb.project_alb.dns_name}"

}
