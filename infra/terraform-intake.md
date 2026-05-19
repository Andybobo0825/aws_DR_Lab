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
- Low-cost baseline does not require Route 53/domain; endpoint failover remains manual unless the optional DNS extension is enabled.
- User now has a Cloudflare-managed domain and requested a Route 53 child-zone delegation path for an advanced DNS failover exercise.
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
| Optional DNS extension | Cloudflare parent zone delegates a child zone such as `dr.example.com` to Route 53 |
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

Optional / disabled by default:

- Route 53 delegated public hosted zone for a Cloudflare child domain, enabled by `enable_route53_delegated_zone=true`.
- Route 53 failover records and health check, enabled by `enable_route53_failover=true`; kept disabled by default because health checks have extra cost.
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
- If Route 53 DNS extension is enabled, expect public hosted zone and health check fixed monthly cost.
- CRR creates cross-region replication requests, data transfer, and DR bucket storage cost; keep demo content small.
- Lifecycle rules expire noncurrent object versions after `noncurrent_version_expiration_days` days.
- Use `force_destroy = true` for demo cleanup; set it to `false` if retaining evidence matters.

## Terraform files

- `infra/versions.tf` — Terraform and provider version constraints.
- `infra/providers.tf` — primary AWS provider and DR alias provider.
- `infra/variables.tf` — configurable names, regions, public access, lifecycle, CRR, SNS, and optional Route 53 flags.
- `infra/main.tf` — S3 website buckets, versioning, lifecycle, encryption, optional public policies, CRR, SNS, optional Route 53.
- `infra/outputs.tf` — bucket names, regions, website endpoints, CRR/SNS status, SNS topic ARN, and Route 53 delegated-zone NS records when enabled.

## Operator decisions before apply

- Choose globally unique S3 bucket names.
- Decide whether to expose demo content publicly via `public_read_enabled=true`.
- Decide whether to set `notification_email` for SNS email subscription.
- If using Cloudflare delegation, choose the child zone name such as `dr.yourdomain.com`, run Terraform, then add the output Route 53 name servers as `NS` records in Cloudflare.

## Route 53 / Cloudflare extension notes

- Implementation profile: optional portfolio extension, not part of the lowest-cost baseline.
- Terraform changes: `aws_route53_zone.delegated`, Route 53 failover records using either the created delegated zone or an existing `route53_zone_id`, and outputs for Cloudflare NS delegation.
- Known S3 limitation: direct S3 website custom domains expect bucket naming that matches the DNS record. A single custom hostname cannot be cleanly failed over between two differently named cross-region S3 website buckets by DNS alone. Treat this Route 53 path as DNS control-plane practice unless the frontend is changed to CloudFront origin failover, Cloudflare Load Balancing, or regional HTTP services that accept the same Host header.
- Validation run: `terraform fmt -recursive infra` and `terraform -chdir=infra validate`.
