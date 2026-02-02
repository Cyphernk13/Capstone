provider "aws" {

  region = "eu-west-1"

}



# Data Sources

data "aws_vpc" "default" { default = true }

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



# Security Groups

resource "aws_security_group" "alb_sg" {

  name   = "project-21-alb-sg"

  vpc_id = data.aws_vpc.default.id

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

  name   = "project-21-ec2-sg"

  vpc_id = data.aws_vpc.default.id

  ingress {

    from_port       = 80

    to_port         = 80

    protocol        = "tcp"

    security_groups = [aws_security_group.alb_sg.id]

  }

  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}



# Load Balancer

resource "aws_lb" "main" {

  name               = "project-21-alb"

  load_balancer_type = "application"

  security_groups    = [aws_security_group.alb_sg.id]

  subnets            = data.aws_subnets.default.ids

}



resource "aws_lb_target_group" "main" {

  name     = "project-21-tg"

  port     = 80

  protocol = "HTTP"

  vpc_id   = data.aws_vpc.default.id

  health_check { path = "/" }

}



resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.main.arn

  port              = "80"

  protocol          = "HTTP"

  default_action {

    type             = "forward"

    target_group_arn = aws_lb_target_group.main.arn

  }

}



# EC2 Instances (The Hybrid Part: Web Server + Stress Tool)

resource "aws_instance" "web" {

  count                  = 2

  ami                    = data.aws_ami.amazon_linux_2.id

  instance_type          = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  subnet_id              = data.aws_subnets.default.ids[count.index]



  # Policy Requirement: Encrypted Volume

  root_block_device {

    encrypted = true

  }



  # User Data: Installs Web Server AND Stress Tool

  user_data = <<-EOF

              #!/bin/bash

              yum update -y

              yum install -y httpd

              systemctl start httpd

              systemctl enable httpd

              echo "<h1>Project 21: Performance Monitoring</h1>" > /var/www/html/index.html



              # INSTALL STRESS TOOL

              amazon-linux-extras install epel -y

              yum install stress -y



              # RUN STRESS (Spike CPU for 10 minutes)

              stress --cpu 1 --timeout 600 &

              EOF



  tags = {

    Name = "Project-21-Server-${count.index}"

  }

}



resource "aws_lb_target_group_attachment" "main" {

  count            = 2

  target_group_arn = aws_lb_target_group.main.arn

  target_id        = aws_instance.web[count.index].id

  port             = 80

}



# The Dashboard

resource "aws_cloudwatch_dashboard" "main" {

  dashboard_name = "Project21-Performance-Dashboard"

  dashboard_body = jsonencode({

    widgets = [

      {

        type   = "metric"

        x      = 0

        y      = 0

        width  = 12

        height = 6

        properties = {

          metrics = [ for i in range(2) : ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.web[i].id] ]

          period  = 60

          stat    = "Average"

          region  = "eu-west-1"

          title   = "EC2 CPU Usage (Load Test)"

        }

      },

      {

        type   = "metric"

        x      = 12

        y      = 0

        width  = 12

        height = 6

        properties = {

          metrics = [ ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix] ]

          period  = 60

          stat    = "Sum"

          region  = "eu-west-1"

          title   = "ALB Traffic (Hits)"

        }

      }

    ]

  })

}



output "alb_dns" {

  value = aws_lb.main.dns_name

}
