#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/sync-site.sh <site_dir> <primary|dr>

Sync static website files to the selected Terraform-managed bucket.
Requires: terraform output available in infra/, aws CLI configured by the operator.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

site_dir="${1:-}"
target="${2:-}"

if [[ -z "$site_dir" || -z "$target" ]]; then
  usage >&2
  exit 2
fi

if [[ ! -d "$site_dir" ]]; then
  echo "site_dir not found: $site_dir" >&2
  exit 2
fi

case "$target" in
  primary) output_name="primary_bucket_name" ;;
  dr) output_name="dr_bucket_name" ;;
  *) echo "target must be primary or dr" >&2; exit 2 ;;
esac

bucket="$(terraform -chdir=infra output -raw "$output_name")"
echo "Syncing $site_dir to s3://$bucket/"
aws s3 sync "$site_dir" "s3://$bucket/" --delete
