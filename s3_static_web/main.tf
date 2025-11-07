resource "aws_s3_bucket" "static_website" {
  bucket = "my-static-website-bucket-demo-4357435"
  tags = {
    Name        = "StaticWebsiteBucket"
    Environment = "Dev"
  }
  
}

resource "aws_s3_bucket_policy" "allow_public_read" {
    bucket = aws_s3_bucket.static_website.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "AllowPublicRead"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.static_website.arn}/*"     
            }]})

    depends_on = [ aws_s3_bucket_public_access_block.public_access_block ]

}

resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.static_website.id
    key    = "index.html"
    source = "/home/sohrab/static_website_hosting/website_files/index.html"
    content_type   = "text/html"
    etag = filemd5("/home/sohrab/static_website_hosting/website_files/index.html")
}

resource "aws_s3_object" "error_html" {
    bucket = aws_s3_bucket.static_website.id
    key    = "error.html"
    source = "/home/sohrab/static_website_hosting/website_files/error.html"
    content_type   = "text/html"
    etag = filemd5("/home/sohrab/static_website_hosting/website_files/error.html")
}

resource "aws_s3_object" "img_uploads" {
    bucket = aws_s3_bucket.static_website.id
    for_each = fileset("/home/sohrab/static_website_hosting/website_files", "*/**")
    key    = each.value
    source = "/home/sohrab/static_website_hosting/website_files/${each.value}"
    content_type   = "image/png"
    etag = filemd5("/home/sohrab/static_website_hosting/website_files/${each.value}")  
}

resource "aws_s3_bucket_website_configuration" "website_config" {
    bucket = aws_s3_bucket.static_website.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
    bucket = aws_s3_bucket.static_website.id
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
}

output "website_endpoint" {
    value = aws_s3_bucket.static_website.website_endpoint
}