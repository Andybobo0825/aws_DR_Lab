#!/usr/bin/env bash
set -euo pipefail

cat <<'TXT'
AWS DR Gameday Lab checklist

1. Confirm primary and DR bucket names.
2. Confirm static website content is uploaded to the primary bucket.
3. Confirm CRR is enabled and primary/DR bucket versioning is active.
4. Confirm SNS topic exists and email subscription is confirmed when notification_email is set.
5. Confirm Route 53 remains disabled because no domain is required for this lab.
6. Confirm RDS is not created; database DR is documented separately from this S3 object DR lab.
7. Review RTO/RPO targets.
8. Execute the failover runbook.
9. Record results in docs/FAILOVER_TEST_REPORT.md.
TXT
