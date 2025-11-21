resource "aws_s3_bucket" "static_website" {
  bucket = "${var.bucket_name}-${random_integer.random_number.result}"
  tags = var.tags
  
}
resource "random_integer" "random_number" {
    min = 10000
    max = 99999
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
    key    = var.index_document
    source = "${path.module}/website_files/index.html"
    content_type   = var.html_content_type
    etag = filemd5("${path.module}/website_files/index.html")
}

resource "aws_s3_object" "error_html" {
    bucket = aws_s3_bucket.static_website.id
    key    = var.error_document
    source = "${path.module}/website_files/error.html"
    content_type   = var.html_content_type
    etag = filemd5("${path.module}/website_files/error.html")
}

resource "aws_s3_object" "img_uploads" {
    bucket = aws_s3_bucket.static_website.id
    for_each = fileset("${path.module}/website_files", "*/**")
    key    = each.value
    source = "${path.module}/website_files/${each.value}"
    content_type   = "image/png"
    etag = filemd5("${path.module}/website_files/${each.value}")  
}

resource "aws_s3_bucket_website_configuration" "website_config" {
    bucket = aws_s3_bucket.static_website.id

    index_document {
        suffix = var.index_document
    }

    error_document {
        key = var.error_document
    }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
    bucket = aws_s3_bucket.static_website.id
      block_public_acls       = var.public_access_block_dependencies["block_public_acls"]
      block_public_policy     = var.public_access_block_dependencies["block_public_policy"]
      ignore_public_acls      = var.public_access_block_dependencies["ignore_public_acls"]
      restrict_public_buckets = var.public_access_block_dependencies["restrict_public_buckets"]
}


output "website_endpoint" {
    value = "http://${aws_s3_bucket.static_website.bucket}.${aws_s3_bucket_website_configuration.website_config.website_domain}"
}