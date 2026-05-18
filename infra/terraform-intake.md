# Terraform Intake — AWS DR Gameday Lab

## Detected app stack

- Repository state: clean portfolio workspace with no application source yet.
- Languages/frameworks: none detected.
- Runtime model: static website hosted from S3 website endpoints.
- Existing infra: none detected before this implementation.

Detection command:

```bash
python3 cloud_deploy_skill/skill/terraform-cloud-planner/scripts/detect_stack.py .
```

## Assumptions

- This is a demo / portfolio DR lab, not production.
- The lab must be low cost and safe to destroy.
- No credentials are used and Terraform is not applied by this task.
- Primary region defaults to `ap-northeast-1`; DR region defaults to `ap-southeast-1`.
- Route 53, SNS, RDS, CloudFront, NAT Gateway, WAF, and paid monitoring are intentionally out of the default path.
- S3 Cross-Region Replication (CRR) is optional and disabled by default because it can create extra request/storage cost.

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
| RTO target | Manual failover exercise target: 15 minutes |
| RPO target | Without CRR: last manual sync; with CRR: S3 replication delay, typically minutes |

## Service inventory

Default resources:

- Primary S3 bucket with website hosting, versioning, SSE-S3 encryption, and lifecycle rules.
- DR S3 bucket with website hosting, versioning, SSE-S3 encryption, and lifecycle rules.
- Public access controls and optional read-only bucket policies for website demos.

Optional resources:

- IAM role and S3 replication configuration for CRR when `enable_crr = true`.

## Sizing profile

- Storage: demo-sized static assets only.
- Compute: none.
- Database: none by default.
- Logs/monitoring: not provisioned by default to avoid cost.

## Security and networking

- Buckets use server-side encryption with S3-managed keys (`AES256`).
- Bucket versioning is enabled to support rollback and replication prerequisites.
- Public website read is disabled by default via `public_read_enabled = false`.
- If public demo hosting is needed, set `public_read_enabled = true` and review content before applying.
- No VPC, subnets, NAT, security groups, or internet gateways are required for S3 website hosting.

## Cost guardrails

- No always-on compute.
- No NAT Gateway, RDS, CloudFront, WAF, or paid alarms by default.
- Lifecycle rules expire noncurrent object versions after `noncurrent_version_expiration_days` days.
- Use `force_destroy = true` only for demo cleanup; set it to `false` if retaining evidence matters.

## Terraform files to create/change

- `infra/versions.tf` — Terraform and provider version constraints.
- `infra/providers.tf` — primary AWS provider and DR alias provider.
- `infra/variables.tf` — configurable names, regions, public access, lifecycle, and CRR flags.
- `infra/main.tf` — S3 website buckets, versioning, lifecycle, encryption, optional policies, optional CRR.
- `infra/outputs.tf` — bucket names, regions, website endpoints, and CRR status.

## Open questions

- Confirm final AWS account naming convention before applying.
- Confirm whether the demo should publicly expose static website content.
- Confirm whether CRR should be enabled for a live gameday exercise.
