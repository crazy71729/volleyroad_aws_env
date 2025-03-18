# S3 Bucket Configuration - 主網站桶
resource "aws_s3_bucket" "website_bucket" {
  bucket = "my-terraform-website1"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# S3 Bucket Configuration - 重定向桶
resource "aws_s3_bucket" "website_redirect_bucket" {
  bucket = "my-terraform-website-redirect"

  website {
    redirect_all_requests_to = "http://my-terraform-website1.s3-website-ap-northeast-1.amazonaws.com"
  }
}

# Disable Block Public Access settings for main website bucket
resource "aws_s3_bucket_public_access_block" "website_public_access" {
  bucket = aws_s3_bucket.website_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Disable Block Public Access settings for redirect bucket
resource "aws_s3_bucket_public_access_block" "website_redirect_public_access" {
  bucket = aws_s3_bucket.website_redirect_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy to allow public read access for main website bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

# S3 Bucket Policy to allow public read access for redirect bucket
resource "aws_s3_bucket_policy" "website_redirect_bucket_policy" {
  bucket = aws_s3_bucket.website_redirect_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_redirect_bucket.arn}/*"
      }
    ]
  })
}

# 定義變數來指定本地路徑
variable "local_directory" {
  default = "/Users/innacheng/Desktop/Volleyball-Rental-System/frontend/build" # 修改為你的本地目錄
}

# 使用本地腳本動態列出目錄下的所有文件
data "local_file" "files" {
  for_each = fileset(var.local_directory, "**") # 遍歷目錄中的所有文件和子目錄
  filename = "${var.local_directory}/${each.value}"
}

# MIME 類型對應表
locals {
  mime_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "json" = "application/json"
    "txt"  = "text/plain"
    "xml"  = "application/xml"
    "map"  = "application/json"
  }
}

# Helper function: 提取文件後綴
locals {
  file_extensions = {
    for key, file in data.local_file.files :
    key => (
      length(split(".", file.filename)) > 1
      ? lower(element(split(".", file.filename), length(split(".", file.filename)) - 1))
      : "" # 沒有後綴則返回空字符串
    )
  }
}

# 將每個文件上傳到 S3 並設置 Metadata (主網站桶)
resource "aws_s3_object" "directory_upload" {
  for_each = data.local_file.files

  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = each.key                        # 文件在 S3 中的名稱（相對於目錄根）
  source       = each.value.filename             # 本地文件的完整路徑
  content_type = lookup(
    local.mime_types,                            # 查找文件的 MIME 類型
    local.file_extensions[each.key],            # 提取文件後綴
    "application/octet-stream"                  # 如果後綴不匹配，使用默認 MIME 類型
  )

  # 可選：設置其他 Metadata
  metadata = {
    uploaded_by = "terraform"
    timestamp   = "${timestamp()}"
  }
}
