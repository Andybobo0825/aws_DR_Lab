variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
  default     = "aws-dr-gameday-lab"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,40}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-42 lowercase letters, numbers, or hyphens, and start/end with an alphanumeric character."
  }
}

variable "environment" {
  description = "Environment label for tags and bucket names."
  type        = string
  default     = "portfolio"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.environment))
    error_message = "environment must be 2-20 lowercase letters, numbers, or hyphens."
  }
}

variable "primary_region" {
  description = "AWS region for the primary static website bucket."
  type        = string
  default     = "ap-northeast-1"
}

variable "dr_region" {
  description = "AWS region for the disaster recovery static website bucket."
  type        = string
  default     = "ap-southeast-1"
}

variable "primary_bucket_name" {
  description = "Optional explicit primary bucket name. Leave null to derive a deterministic name from project/environment/region."
  type        = string
  default     = null
}

variable "dr_bucket_name" {
  description = "Optional explicit DR bucket name. Leave null to derive a deterministic name from project/environment/region."
  type        = string
  default     = null
}

variable "public_read_enabled" {
  description = "When true, attaches read-only bucket policies for public S3 website demos. Keep false unless demo content is approved for public access."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow Terraform to delete non-empty demo buckets during destroy. Disable for retained evidence."
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days before old object versions expire. Controls demo storage cost."
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1 && var.noncurrent_version_expiration_days <= 365
    error_message = "noncurrent_version_expiration_days must be between 1 and 365."
  }
}

variable "enable_crr" {
  description = "Enable S3 Cross-Region Replication from primary to DR bucket. Disabled by default for minimum cost."
  type        = bool
  default     = false
}

variable "replication_prefix" {
  description = "Object prefix to replicate when CRR is enabled. Empty string replicates all objects."
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags merged into all supported resources."
  type        = map(string)
  default     = {}
}
