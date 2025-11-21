variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
  default     = "my-static-website-bucket-demo"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {
    Environment = "Dev"
    Project     = "StaticWebsitebucket"
  }
}

variable "html_content_type" {
  description = "The content type for the index document"
  type        = string
  default     = "text/html"
}

variable "index_document" {
  description = "The index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The error document for the website"
  type        = string
  default     = "error.html"
}

variable "block_public_acls" {
  description = "Whether to block public ACLs on the bucket"
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs on the bucket"
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether to block public policies on the bucket"
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether to restrict public buckets"
  type        = bool
  default     = false
}

variable "public_access_block_dependencies" {
  description = "Dependencies for the public access block"
  type        = map(string)
  default     = {
    block_public_acls       = "false"
    block_public_policy     = "false"
    ignore_public_acls      = "false"
    restrict_public_buckets = "false"
  }
  
}



