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


output "route53_delegated_zone_id" {
  description = "Route 53 delegated child hosted zone ID. Null when enable_route53_delegated_zone=false."
  value       = try(aws_route53_zone.delegated[0].zone_id, null)
}

output "route53_delegated_zone_name_servers" {
  description = "Name servers to create as NS records in the Cloudflare parent zone for the delegated child domain."
  value       = try(aws_route53_zone.delegated[0].name_servers, [])
}

output "route53_failover_record_name" {
  description = "Route 53 failover DNS record name. Null when Route 53 failover is disabled."
  value       = var.enable_route53_failover ? local.route53_failover_record_name : null
}

output "route53_primary_health_check_id" {
  description = "Primary website Route 53 health check ID. Null when Route 53 failover is disabled."
  value       = try(aws_route53_health_check.primary_site[0].id, null)
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
