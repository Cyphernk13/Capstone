output "iam_user_name" {

  value = aws_iam_user.this.name

}



output "attached_policy_arn" {

  value = aws_iam_policy.s3_read.arn

}
