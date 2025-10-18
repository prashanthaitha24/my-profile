resource "aws_s3_bucket" "this" { bucket=var.bucket_name, force_destroy=true, tags=var.tags }
resource "aws_s3_bucket_website_configuration" "site" { bucket=aws_s3_bucket.this.id
  index_document { suffix=var.website_index } error_document { key=var.website_index }
}
resource "aws_s3_bucket_public_access_block" "pab" { bucket=aws_s3_bucket.this.id
  block_public_acls=true, block_public_policy=true, ignore_public_acls=true, restrict_public_buckets=true
}
