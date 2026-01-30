# 1. Create IAM User

resource "aws_iam_user" "this" {

  name = var.iam_user_name

}



# 2. Create IAM Policy (using the variable)

resource "aws_iam_policy" "s3_read" {

  name   = "S3ReadOnlyFromTerraform-ujjawal"

  policy = var.s3_read_policy

}



# 3. Attach policy to user

resource "aws_iam_user_policy_attachment" "attach" {

  user       = aws_iam_user.this.name

  policy_arn = aws_iam_policy.s3_read.arn

}
