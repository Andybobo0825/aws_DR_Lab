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

output "route53_failover_enabled" {
  description = "Whether optional Route 53 failover records are enabled."
  value       = var.enable_route53_failover
}

output "sns_notifications_enabled" {
  description = "Whether optional SNS gameday notifications are enabled."
  value       = var.enable_sns_notifications
}

output "rds_restore_demo_enabled" {
  description = "Documentation-only RDS restore exercise flag; this minimal lab does not create RDS resources."
  value       = var.enable_rds_restore_demo
}

output "sns_topic_arn" {
  description = "SNS topic ARN for DR gameday notifications. Null when enable_sns_notifications=false."
  value       = try(aws_sns_topic.gameday[0].arn, null)
}
