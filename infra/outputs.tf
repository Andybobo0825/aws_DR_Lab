output "primary_bucket_name" {
  description = "Primary static website bucket name."
  value       = aws_s3_bucket.primary_site.bucket
}

output "dr_bucket_name" {
  description = "DR static website bucket name."
  value       = aws_s3_bucket.dr_site.bucket
}

output "primary_region" {
  description = "Primary AWS region."
  value       = var.primary_region
}

output "dr_region" {
  description = "DR AWS region."
  value       = var.dr_region
}

output "primary_website_endpoint" {
  description = "Primary S3 website endpoint. Public access requires public_read_enabled=true."
  value       = aws_s3_bucket_website_configuration.primary_site.website_endpoint
}

output "dr_website_endpoint" {
  description = "DR S3 website endpoint. Public access requires public_read_enabled=true."
  value       = aws_s3_bucket_website_configuration.dr_site.website_endpoint
}

output "crr_enabled" {
  description = "Whether Cross-Region Replication is enabled."
  value       = var.enable_crr
}
