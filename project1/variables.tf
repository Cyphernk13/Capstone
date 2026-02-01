variable "aws_region" {

  description = "AWS region"

  type        = string

  default     = "eu-west-1"

}



variable "instance_type" {

  description = "EC2 instance type"

  type        = string

  default     = "t2.micro"

}



variable "key_name" {

  description = "Name of the existing AWS key pair"

  type        = string

  default     = "terraform" 

  # IMPORTANT: Check your provided PEM file name. 

  # If the file is 'terraform.pem', the key_name is usually 'terraform'.

  # If you don't know it, we can comment this out in main.tf later.

}
