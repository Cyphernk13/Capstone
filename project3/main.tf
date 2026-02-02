# 1. Provider

provider "aws" {

  region = "eu-west-1"

}



# 2. Data Sources (to find VPC, Subnet, and AMI automatically)

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



# 3. Security Group (Allow SSH just in case)

resource "aws_security_group" "monitoring_sg" {

  name   = "project-3-monitoring-sg"

  vpc_id = data.aws_vpc.default.id



  ingress {

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

}



# 4. EC2 Instance with CPU Spike Script

resource "aws_instance" "monitor_me" {

  ami                    = data.aws_ami.amazon_linux_2.id

  instance_type          = "t2.micro"

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  subnet_id              = data.aws_subnets.default.ids[0]



  root_block_device {

    encrypted = true

  }



  # This script runs on startup to create the CPU spike

  user_data = <<-EOF

              #!/bin/bash

              amazon-linux-extras install epel -y

              yum install stress-ng -y

              # Wait 2 minutes for initialization, then spike CPU for 10 minutes

              sleep 120

              stress-ng --cpu 1 --cpu-load 100 --timeout 600

              EOF



  tags = {

    Name = "Project3-Target-Instance"

  }

}



# 5. CloudWatch Alarm

resource "aws_cloudwatch_metric_alarm" "cpu_spike_alarm" {

  alarm_name          = "Project3-High-CPU-Alert"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods  = "1"

  metric_name         = "CPUUtilization"

  namespace           = "AWS/EC2"

  period              = "60"

  statistic           = "Average"

  threshold           = "70" # Alarm triggers if CPU > 70%

  alarm_description   = "Monitor EC2 CPU spikes"



  dimensions = {

    InstanceId = aws_instance.monitor_me.id

  }

}



output "instance_id" {

  value = aws_instance.monitor_me.id

}
