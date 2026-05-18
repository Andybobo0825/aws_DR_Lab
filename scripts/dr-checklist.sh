#!/usr/bin/env bash
set -euo pipefail

cat <<'TXT'
AWS DR Gameday Lab checklist

1. Confirm primary and DR bucket names.
2. Confirm static website content is uploaded to the primary bucket.
3. Confirm whether CRR is enabled.
4. Confirm Route 53 failover is intentionally disabled by default.
5. Confirm SNS and RDS are intentionally disabled by default.
6. Review RTO/RPO targets.
7. Execute the failover runbook.
8. Record results in docs/FAILOVER_TEST_REPORT.md.
TXT
