variable "aws_region" {

  description = "AWS region"

  type        = string

  default     = "eu-west-1"

}



variable "iam_user_name" {

  description = "IAM user name"

  type        = string

  default     = "project4-user-ujjawal" 

}



variable "s3_read_policy" {

  description = "S3 read-only IAM policy in JSON"

  type        = string

  default     = <<EOF

{

  "Version": "2012-10-17",

  "Statement": [

    {

      "Effect": "Allow",

      "Action": [

        "s3:Get*",

        "s3:List*"

      ],

      "Resource": "*"

    }

  ]

}

EOF

}
