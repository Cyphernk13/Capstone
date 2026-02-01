# Project 23: IAM Role Based Access



## Goal

Securely access S3 buckets from an EC2 instance without hardcoding credentials.



## Implementation

1. **IAM Role:** Verified the instance has an attached IAM Role with S3 permissions.

2. **Verification:**

   - Executed `aws s3 ls` from the terminal.

   - Confirmed successful listing of all S3 buckets.



## Result

The EC2 instance successfully authenticated using the IAM Role's temporary credentials.
