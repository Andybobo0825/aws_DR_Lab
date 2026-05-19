locals {
  name_prefix         = lower("${var.project_name}-${var.environment}")
  primary_bucket_name = coalesce(var.primary_bucket_name, "${local.name_prefix}-primary-${var.primary_region}")
  dr_bucket_name      = coalesce(var.dr_bucket_name, "${local.name_prefix}-dr-${var.dr_region}")

  route53_delegated_zone_name          = var.route53_delegated_zone_name == null ? null : trimsuffix(var.route53_delegated_zone_name, ".")
  route53_default_failover_record_name = local.route53_delegated_zone_name == null ? null : "www.${local.route53_delegated_zone_name}"
  route53_failover_record_name         = try(trimsuffix(coalesce(var.failover_record_name, local.route53_default_failover_record_name), "."), null)
  route53_failover_zone_id             = var.enable_route53_delegated_zone ? aws_route53_zone.delegated[0].zone_id : var.route53_zone_id

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Lab         = "aws-dr-gameday"
      CostProfile = "minimal"
    },
    var.additional_tags
  )
}

resource "aws_s3_bucket" "primary_site" {
  bucket        = local.primary_bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Role = "primary-static-site"
  })
}

resource "aws_s3_bucket" "dr_site" {
  provider      = aws.dr
  bucket        = local.dr_bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Role = "dr-static-site"
  })
}

resource "aws_s3_bucket_ownership_controls" "primary_site" {
  bucket = aws_s3_bucket.primary_site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "dr_site" {
  provider = aws.dr
  bucket   = aws_s3_bucket.dr_site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "primary_site" {
  bucket = aws_s3_bucket.primary_site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = !var.public_read_enabled
  restrict_public_buckets = !var.public_read_enabled
}

resource "aws_s3_bucket_public_access_block" "dr_site" {
  provider = aws.dr
  bucket   = aws_s3_bucket.dr_site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = !var.public_read_enabled
  restrict_public_buckets = !var.public_read_enabled
}

resource "aws_s3_bucket_server_side_encryption_configuration" "primary_site" {
  bucket = aws_s3_bucket.primary_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dr_site" {
  provider = aws.dr
  bucket   = aws_s3_bucket.dr_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "primary_site" {
  bucket = aws_s3_bucket.primary_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "dr_site" {
  provider = aws.dr
  bucket   = aws_s3_bucket.dr_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "primary_site" {
  bucket = aws_s3_bucket.primary_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_website_configuration" "dr_site" {
  provider = aws.dr
  bucket   = aws_s3_bucket.dr_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "primary_site" {
  bucket = aws_s3_bucket.primary_site.id

  rule {
    id     = "expire-old-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "dr_site" {
  provider = aws.dr
  bucket   = aws_s3_bucket.dr_site.id

  rule {
    id     = "expire-old-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}

data "aws_iam_policy_document" "primary_public_read" {
  count = var.public_read_enabled ? 1 : 0

  statement {
    sid     = "AllowPublicReadForWebsiteDemo"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.primary_site.arn}/*"]
  }
}

data "aws_iam_policy_document" "dr_public_read" {
  count = var.public_read_enabled ? 1 : 0

  statement {
    sid     = "AllowPublicReadForWebsiteDemo"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.dr_site.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "primary_public_read" {
  count = var.public_read_enabled ? 1 : 0

  bucket = aws_s3_bucket.primary_site.id
  policy = data.aws_iam_policy_document.primary_public_read[0].json

  depends_on = [aws_s3_bucket_public_access_block.primary_site]
}

resource "aws_s3_bucket_policy" "dr_public_read" {
  provider = aws.dr
  count    = var.public_read_enabled ? 1 : 0

  bucket = aws_s3_bucket.dr_site.id
  policy = data.aws_iam_policy_document.dr_public_read[0].json

  depends_on = [aws_s3_bucket_public_access_block.dr_site]
}

data "aws_iam_policy_document" "replication_assume_role" {
  count = var.enable_crr ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication" {
  count = var.enable_crr ? 1 : 0

  name               = "${local.name_prefix}-s3-replication"
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role[0].json

  tags = merge(local.common_tags, {
    Role = "s3-crr-replication"
  })
}

data "aws_iam_policy_document" "replication" {
  count = var.enable_crr ? 1 : 0

  statement {
    sid = "ReadReplicationSource"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.primary_site.arn]
  }

  statement {
    sid = "ReadSourceObjectVersions"
    actions = [
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionTagging"
    ]
    resources = ["${aws_s3_bucket.primary_site.arn}/*"]
  }

  statement {
    sid = "ReplicateToDrBucket"
    actions = [
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ReplicateTags"
    ]
    resources = ["${aws_s3_bucket.dr_site.arn}/*"]
  }
}

resource "aws_iam_role_policy" "replication" {
  count = var.enable_crr ? 1 : 0

  name   = "${local.name_prefix}-s3-replication"
  role   = aws_iam_role.replication[0].id
  policy = data.aws_iam_policy_document.replication[0].json
}

resource "aws_s3_bucket_replication_configuration" "primary_to_dr" {
  count = var.enable_crr ? 1 : 0

  bucket = aws_s3_bucket.primary_site.id
  role   = aws_iam_role.replication[0].arn

  rule {
    id     = "replicate-static-site-to-dr"
    status = "Enabled"

    filter {
      prefix = var.replication_prefix
    }

    destination {
      bucket        = aws_s3_bucket.dr_site.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = var.replicate_delete_markers ? "Enabled" : "Disabled"
    }
  }

  depends_on = [
    aws_iam_role_policy.replication,
    aws_s3_bucket_versioning.primary_site,
    aws_s3_bucket_versioning.dr_site
  ]
}

resource "aws_sns_topic" "gameday" {
  count = var.enable_sns_notifications ? 1 : 0

  name = "${local.name_prefix}-gameday"

  tags = merge(local.common_tags, {
    Role = "dr-gameday-notifications"
  })
}

resource "aws_sns_topic_subscription" "gameday_email" {
  count = var.enable_sns_notifications && var.notification_email != null ? 1 : 0

  topic_arn = aws_sns_topic.gameday[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}


resource "aws_route53_zone" "delegated" {
  count = var.enable_route53_delegated_zone ? 1 : 0

  name    = local.route53_delegated_zone_name
  comment = "Delegated child zone for the AWS DR gameday lab. Add these NS records in the parent DNS provider."

  tags = merge(local.common_tags, {
    Role = "route53-delegated-child-zone"
  })
}

resource "aws_route53_health_check" "primary_site" {
  count = var.enable_route53_failover ? 1 : 0

  fqdn              = aws_s3_bucket_website_configuration.primary_site.website_endpoint
  port              = 80
  type              = "HTTP"
  resource_path     = "/index.html"
  failure_threshold = 3
  request_interval  = 30

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-primary-site"
    Role = "route53-failover-health-check"
  })
}

resource "aws_route53_record" "primary_failover" {
  count = var.enable_route53_failover ? 1 : 0

  zone_id = local.route53_failover_zone_id
  name    = local.route53_failover_record_name
  type    = "CNAME"
  ttl     = 60

  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary_site[0].id
  records         = [aws_s3_bucket_website_configuration.primary_site.website_endpoint]
}

resource "aws_route53_record" "dr_failover" {
  count = var.enable_route53_failover ? 1 : 0

  zone_id = local.route53_failover_zone_id
  name    = local.route53_failover_record_name
  type    = "CNAME"
  ttl     = 60

  set_identifier = "dr"

  failover_routing_policy {
    type = "SECONDARY"
  }

  records = [aws_s3_bucket_website_configuration.dr_site.website_endpoint]
}
