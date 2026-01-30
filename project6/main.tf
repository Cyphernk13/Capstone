terraform {

  required_version = ">= 1.0.0"

}



provider "local" {}



resource "local_file" "demo" {

  filename = "${path.module}/hello.txt"

  content  = "Updated Terraform code - PR raised using Git workflow!"

}
