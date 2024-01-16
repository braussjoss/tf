locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
    environment  = var.environment
  }
  bucket_name = lower("${local.naming_prefix}-bucket-${random_integer.bucket.result}")
  website_content = {
    website = "website/index.html"
    logo    = "website/prometheus.png"
  }

  naming_prefix = "${var.naming_prefix}-${var.environment}"
}

# Generating a random name between 10000 and 99999 for a aws_alb_listener_rule resource:
resource "random_integer" "bucket" {
  min = 10000
  max = 99999
}
