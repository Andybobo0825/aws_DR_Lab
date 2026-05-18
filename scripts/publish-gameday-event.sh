#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/publish-gameday-event.sh <message>

Publish a DR gameday notification to the Terraform-managed SNS topic.
Requires: terraform output available in infra/, aws CLI configured by the operator.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

message="${1:-}"
if [[ -z "$message" ]]; then
  usage >&2
  exit 2
fi

topic_arn="$(terraform -chdir=infra output -raw sns_topic_arn 2>/dev/null || true)"
if [[ -z "$topic_arn" || "$topic_arn" == "null" ]]; then
  echo "sns_topic_arn is empty. Apply with enable_sns_notifications=true first." >&2
  exit 2
fi

if [[ ! "$topic_arn" =~ ^arn:aws[a-zA-Z-]*:sns:([^:]+):[0-9]{12}:.+ ]]; then
  echo "sns_topic_arn is not a valid SNS topic ARN: $topic_arn" >&2
  exit 2
fi

# SNS publish must call the same regional endpoint as the TopicArn. Do not rely on
# the operator's default AWS CLI region, which may point at a different region.
topic_region="${BASH_REMATCH[1]}"

aws sns publish \
  --region "$topic_region" \
  --topic-arn "$topic_arn" \
  --subject "AWS DR Gameday Lab" \
  --message "$message"
