# Terraform Intake — AWS DR Gameday Lab

## Detected app stack

- Repository state: portfolio workspace for an AWS DR gameday lab.
- Languages/frameworks: no application backend; static website demo content only.
- Runtime model: S3 static website endpoints.
- Existing infra: Terraform under `infra/`.

Detection command used during initial scaffold:

```bash
python3 cloud_deploy_skill/skill/terraform-cloud-planner/scripts/detect_stack.py .
```

## Assumptions

- This is a portfolio DR lab, not production.
- The lab should demonstrate **S3 + SNS + CRR** as one complete project, not separate first/second versions.
- No Route 53/domain is required for the current lab; endpoint failover is manual.
- No credentials are committed; Terraform apply is an operator action.
- Primary region defaults to `ap-northeast-1`; DR region defaults to `ap-southeast-1`.
- RDS is documented as a different DR pattern, but not created by this S3 object replication lab.

## Selected cloud profile

| Field | Decision |
| --- | --- |
| Cloud provider | AWS |
| Environment purpose | Portfolio / DR gameday demo |
| Primary region | `ap-northeast-1` |
| DR region | `ap-southeast-1` |
| Runtime | S3 static website |
| Scale | Low-traffic demo content |
| Availability | Primary + standby DR S3 buckets in two regions |
| Notification | SNS topic, optional email subscription |
| Replication | S3 CRR enabled by default |
| RTO target | 10 minutes for manual endpoint failover |
| RPO target | S3 replication delay, normally measured in minutes for small demo objects |

## Service inventory

Default resources:

- Primary S3 bucket with website hosting, versioning, SSE-S3 encryption, and lifecycle rules.
- DR S3 bucket with website hosting, versioning, SSE-S3 encryption, and lifecycle rules.
- S3 Cross-Region Replication from primary bucket to DR bucket.
- Delete marker replication disabled by default to protect the DR copy from accidental primary deletes.
- IAM role and policy required for S3 replication.
- SNS topic for DR gameday notifications.
- Optional SNS email subscription when `notification_email` is set.
- Public access controls and optional read-only bucket policies for website demos.

Disabled by default:

- Route 53 failover records and health check, because there is currently no domain and health checks have extra cost.
- RDS/Aurora resources, because database DR is a separate design from S3 object replication.
- EC2, NAT Gateway, CloudFront, WAF.

## Sizing profile

- Storage: small demo static assets only.
- Compute: none.
- Database: none.
- Notifications: one SNS topic; optional email subscription.

## Security and networking

- Buckets use server-side encryption with S3-managed keys (`AES256`).
- Bucket versioning is enabled to support rollback and replication prerequisites.
- Public website read is disabled by default via `public_read_enabled = false`; set it to `true` only for approved demo content.
- No VPC, subnets, NAT, security groups, or internet gateways are required for S3 website hosting.
- SNS email subscription requires recipient confirmation before email delivery.

## Cost guardrails

- No always-on compute.
- No NAT Gateway, RDS, CloudFront, WAF, or paid Route 53 health check by default.
- CRR creates cross-region replication requests, data transfer, and DR bucket storage cost; keep demo content small.
- Lifecycle rules expire noncurrent object versions after `noncurrent_version_expiration_days` days.
- Use `force_destroy = true` for demo cleanup; set it to `false` if retaining evidence matters.

## Terraform files

- `infra/versions.tf` — Terraform and provider version constraints.
- `infra/providers.tf` — primary AWS provider and DR alias provider.
- `infra/variables.tf` — configurable names, regions, public access, lifecycle, CRR, SNS, and optional Route 53 flags.
- `infra/main.tf` — S3 website buckets, versioning, lifecycle, encryption, optional public policies, CRR, SNS, optional Route 53.
- `infra/outputs.tf` — bucket names, regions, website endpoints, CRR/SNS status, SNS topic ARN.

## Operator decisions before apply

- Choose globally unique S3 bucket names.
- Decide whether to expose demo content publicly via `public_read_enabled=true`.
- Decide whether to set `notification_email` for SNS email subscription.
