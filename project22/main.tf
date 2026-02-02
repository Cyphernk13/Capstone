provider "aws" {

  region = "eu-west-1"

}



# Generate a unique suffix so the bucket name doesn't conflict

resource "random_id" "bucket_suffix" {

  byte_length = 4

}



# 1. Create the Log Archive Bucket

resource "aws_s3_bucket" "log_archive" {

  bucket = "project-22-log-archive-${random_id.bucket_suffix.hex}"



  tags = {

    Name        = "Log Archive"

    Project     = "Project22"

  }

}



# 2. Add Lifecycle Rule (The core requirement)

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {

  bucket = aws_s3_bucket.log_archive.id



  rule {

    id     = "archive-and-delete-logs"

    status = "Enabled"



    # Transition to "Glacier Instant Retrieval" (Cheaper) after 30 days

    transition {

      days          = 30

      storage_class = "GLACIER_IR"

    }



    # Permanently delete after 90 days

    expiration {

      days = 90

    }

  }

}



output "bucket_name" {

  value = aws_s3_bucket.log_archive.id

}
