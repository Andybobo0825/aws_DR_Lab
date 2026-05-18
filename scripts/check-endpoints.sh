#!/usr/bin/env bash
set -euo pipefail

endpoint_for() {
  local output_name="$1"
  terraform -chdir=infra output -raw "$output_name"
}

check_url() {
  local label="$1"
  local endpoint="$2"
  local url="http://${endpoint}/"
  local code
  code="$(curl -L -sS -o /dev/null -w '%{http_code}' --connect-timeout 5 --max-time 15 "$url" || true)"
  printf '%s %s %s\n' "$label" "$code" "$url"
}

primary="$(endpoint_for primary_website_endpoint)"
dr="$(endpoint_for dr_website_endpoint)"

check_url "primary" "$primary"
check_url "dr" "$dr"
