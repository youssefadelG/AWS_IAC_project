resource "aws_s3_bucket" "web_bucket" {
  bucket        = "joecloudkodeweb-bucket-1"
  force_destroy = true
  tags = {
    Name = "CloudkodeS3BucketofJoe"
  }
}

# Create an S3 bucket policy for full access
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowFullAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        },
        Action = "s3:*",
        Resource = [
          "${aws_s3_bucket.web_bucket.arn}",
          "${aws_s3_bucket.web_bucket.arn}/*"
        ]
      }
    ]
  })
}
