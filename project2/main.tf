# 1. Create S3 Bucket

resource "aws_s3_bucket" "website_bucket" {

  bucket = "project2-s3-website-ujjawal-696969"  

}



# 2. Configure Static Website Hosting

resource "aws_s3_bucket_website_configuration" "website_config" {

  bucket = aws_s3_bucket.website_bucket.id



  index_document {

    suffix = "index.html"

  }

}



# 3. Disable "Block Public Access" (Make it public)

resource "aws_s3_bucket_public_access_block" "public_access" {

  bucket = aws_s3_bucket.website_bucket.id



  block_public_acls       = false

  block_public_policy     = false

  ignore_public_acls      = false

  restrict_public_buckets = false

}



# 4. Bucket Policy (Allow anyone to read)

resource "aws_s3_bucket_policy" "public_policy" {

  bucket = aws_s3_bucket.website_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.public_access]



  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [{

      Effect = "Allow"

      Principal = "*"

      Action = "s3:GetObject"

      Resource = "${aws_s3_bucket.website_bucket.arn}/*"

    }]

  })

}



# 5. Upload index.html

resource "aws_s3_object" "index_file" {

  bucket       = aws_s3_bucket.website_bucket.id

  key          = "index.html"

  source       = "index.html"

  content_type = "text/html"

}
