# Find your default VPC automatically

data "aws_vpc" "default" {

  default = true

}



# Find subnets inside that VPC

data "aws_subnets" "all" {

  filter {

    name   = "vpc-id"

    values = [data.aws_vpc.default.id]

  }

}
